import 'dart:io';

Future<void> bench(
  String name,
  String cmd, {
  required String path,
  required String benchmarkCmd,
  String? warmupCmd,
  String? setupCmd,
  String? versionCmd,
  String? cwd,
}) async {
  print('=== BEGIN $name ===');

  final log = (File('$path/$name.log')..createSync(recursive: true))
      .openWrite(mode: FileMode.append);

  ProcessResult run(String cmd, [StringSink? sink]) {
    ProcessResult? r;
    try {
      r = Process.runSync('sh', ['-c', cmd], workingDirectory: cwd);
      (sink ?? log)
        ..writeln(r.stdout)
        ..writeln(r.stderr);
      return r;
    } catch (err, st) {
      Error.throwWithStackTrace('CMD "$cmd" [${r?.exitCode}]: $err', st);
    }
  }

  Process? process;
  try {
    if (versionCmd != null) run(versionCmd);
    if (setupCmd != null) run(setupCmd);

    process = await Process.start(
      'sh',
      ['-c', 'time $cmd'],
      workingDirectory: cwd,
      mode: ProcessStartMode.normal,
    );
    process.stderr.forEach((bytes) => log.add(bytes)).whenComplete(log.close);

    // Scientifically chosen, *correct* wait period for the server to come up.
    await Future.delayed(Duration(seconds: 2));

    run(warmupCmd ?? benchmarkCmd, StringBuffer());
    print(run(benchmarkCmd).stdout);
  } finally {
    if (process != null) {
      run('kill \$(lsof -t -i:3000)');
    }
  }

  print('=== END: $name ===\n');
}

Future<void> runHelloWorld() async {
  const benchmarkCmd = 'wrk -c 10 -t 10 -d 30s --latency http://localhost:3000';
  const warmupCmd = 'wrk -c 10 -t 10 -d 5s http://localhost:3000';

  Future<void> run(
    String name,
    String cmd, {
    String? setupCmd,
    String? versionCmd,
    String? cwd,
  }) =>
      bench(
        name,
        cmd,
        path: 'output_hello_world',
        setupCmd: setupCmd,
        versionCmd: versionCmd,
        cwd: cwd,
        benchmarkCmd: benchmarkCmd,
        warmupCmd: warmupCmd,
      );

  await run('node', 'node node.js', versionCmd: 'node -v');
  await run('deno', 'deno run --allow-net deno.ts',
      versionCmd: 'deno --version');
  await run('bun', 'bun bun.ts', versionCmd: 'bun --version');

  await run('go', '/tmp/goserver',
      setupCmd: 'go build -o /tmp/goserver go.go', versionCmd: 'go version');

  const dartVersionCmd = 'dart --version';
  await run('dart_jit', 'dart run dart.dart', versionCmd: dartVersionCmd);
  await run(
    'dart_aot',
    '/tmp/dart_aot',
    setupCmd: 'dart compile exe dart.dart -o /tmp/dart_aot',
    versionCmd: dartVersionCmd,
  );

  const axumBuild =
      'cargo +nightly build -Z unstable-options --release --out-dir=/tmp/';
  const rustVersionCmd = 'cargo +nightly version';
  await run('axum_mt', '/tmp/hello_world_axum_server m',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');
  await run('axum_st', '/tmp/hello_world_axum_server',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');

  final dartAxumVersionCmd = '$dartVersionCmd && $rustVersionCmd';
  await run(
    'dart_axum_jit',
    'dart --enable-experiment=native-assets run bin/main.dart',
    setupCmd: 'dart --enable-experiment=native-assets run bin/main.dart build',
    versionCmd: dartAxumVersionCmd,
    cwd: 'dart_axum_tokio',
  );
  await run(
    'dart_axum_aot',
    '/tmp/dart_axum_aot',
    setupCmd:
        'dart --enable-experiment=native-assets compile exe bin/main.dart -o /tmp/dart_axum_aot',
    versionCmd: dartAxumVersionCmd,
    cwd: 'dart_axum_tokio',
  );
}

Future<void> runJsonEcho() async {
  const script = 'wrk_post.lua';
  final benchmarkCmd =
      'wrk -c 10 -t 10 -d 30s --latency -s $script http://localhost:3000/';
  final warmupCmd = 'wrk -c 10 -t 10 -d 5s -s $script http://localhost:3000/';

  Future<void> run(
    String name,
    String cmd, {
    String? setupCmd,
    String? versionCmd,
    String? cwd,
  }) =>
      bench(
        name,
        cmd,
        path: 'output_json_echo',
        setupCmd: setupCmd,
        versionCmd: versionCmd,
        cwd: cwd,
        benchmarkCmd: benchmarkCmd,
        warmupCmd: warmupCmd,
      );

  await run('node', 'node node.js', versionCmd: 'node -v');
  await run('deno', 'deno run --allow-net deno.ts',
      versionCmd: 'deno --version');
  await run('bun', 'bun bun.ts', versionCmd: 'bun --version');

  await run('go', '/tmp/goserver',
      setupCmd: 'go build -o /tmp/goserver go.go', versionCmd: 'go version');

  const dartVersionCmd = 'dart --version';
  await run('dart_jit', 'dart run dart.dart', versionCmd: dartVersionCmd);
  await run(
    'dart_aot',
    '/tmp/dart_aot',
    setupCmd: 'dart compile exe dart.dart -o /tmp/dart_aot',
    versionCmd: dartVersionCmd,
  );

  const axumBuild =
      'cargo +nightly build -Z unstable-options --release --out-dir=/tmp/';
  const rustVersionCmd = 'cargo +nightly version';
  await run('axum_mt_serde', '/tmp/hello_world_axum_server -m',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');
  await run('axum_st_serde', '/tmp/hello_world_axum_server',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');

  await run('axum_mt_simd', '/tmp/hello_world_axum_server -m -s',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');
  await run('axum_st_simd', '/tmp/hello_world_axum_server -s',
      setupCmd: axumBuild, versionCmd: rustVersionCmd, cwd: 'axum');

  final dartAxumVersionCmd = '$dartVersionCmd && $rustVersionCmd';
  await run(
    'dart_axum_aot',
    '/tmp/dart_axum_aot',
    setupCmd:
        'dart --enable-experiment=native-assets compile exe bin/main.dart -o /tmp/dart_axum_aot',
    versionCmd: dartAxumVersionCmd,
    cwd: 'dart_axum_tokio',
  );
}

Future<void> main(List<String> arguments) async {
  //await runHelloWorld();
  await runJsonEcho();
}
