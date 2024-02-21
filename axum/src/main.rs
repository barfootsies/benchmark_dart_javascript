use axum::{
    routing::{get, post},
    Router,
};
use clap::Parser;
use lazy_static::lazy_static;
use serde_json::Value;
use simd_json::{to_borrowed_value, to_string};
use tokio::runtime::{Builder, Runtime};

lazy_static! {
    static ref MTRT: Runtime = Builder::new_multi_thread().enable_all().build().unwrap();
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    #[arg(long, short)]
    pub multi_threaded: bool,

    #[arg(long, short)]
    pub simd_json: bool,
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let args = Args::parse();

    let runtime = match args.multi_threaded {
        false => tokio::runtime::Handle::current(),
        true => MTRT.handle().clone(),
    };

    runtime
        .spawn(async move {
            let address = "0.0.0.0:3000";
            println!(
                "Listening on {address} ({env}) using {json}",
                env = if args.multi_threaded { "MT" } else { "ST" },
                json = if args.simd_json { "SIMD" } else { "Serde" },
            );

            let handler = || async { "Hello World" };
            let serde_post_handler = |req: axum::extract::Request| async {
                let b = axum::body::to_bytes(req.into_body(), usize::MAX)
                    .await
                    .unwrap();
                let v: Value = serde_json::from_slice(&b).unwrap();
                serde_json::to_string(&v).unwrap()
            };
            let simd_post_handler = |req: axum::extract::Request| async {
                let b: axum::body::Bytes = axum::body::to_bytes(req.into_body(), usize::MAX)
                    .await
                    .unwrap();
                let mut vec = b.to_vec();
                let v: simd_json::BorrowedValue = to_borrowed_value(vec.as_mut_slice()).unwrap();
                to_string(&v).unwrap()
            };

            let app = Router::new().route("/", get(handler)).route(
                "/",
                if args.simd_json {
                    post(simd_post_handler)
                } else {
                    post(serde_post_handler)
                },
            );

            let listener = tokio::net::TcpListener::bind(address).await.unwrap();
            axum::serve(listener, app).await.unwrap();
        })
        .await
        .unwrap();
}
