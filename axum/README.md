# Axum HelloWorld and JSON echo HTTP Server

## Run PGO

Install pgo utility and build an introspected server:

    cargo install cargo-pgo
    cargo pgo build

Run the output binary with `-m -a` for multi-threaded and auto-termination.
Note, the profile data will only be written upon "successful" termination.
While the server is running, hammer it with e.g. `wrk`:

    wrk -c 10 -t 10 -d 60s --latency -s wrk_post.lua 'http://localhost:3000/'

Afterwards build an optimized binary with:

    cargo pgo optimize

That's it.

## Results

We found a 36% reduction in avg Latency and a 58% increase in throughput.

Before:

```
Running 10s test @ http://localhost:3000/
  10 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   277.29us   72.44us   1.15ms   83.31%
    Req/Sec     3.60k   217.95     4.81k    83.66%
  Latency Distribution
     50%  268.00us
     75%  290.00us
     90%  367.00us
     99%  507.00us
  361778 requests in 10.10s, 8.30GB read
Requests/sec:  35821.90
Transfer/sec:    841.73MB
```

After:
```
Running 10s test @ http://localhost:3000/
  10 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   175.23us   26.44us   1.05ms   66.79%
    Req/Sec     5.69k   120.66     6.00k    73.76%
  Latency Distribution
     50%  180.00us
     75%  194.00us
     90%  204.00us
     99%  241.00us
  571877 requests in 10.10s, 13.12GB read
Requests/sec:  56621.88
Transfer/sec:      1.30GB
```

