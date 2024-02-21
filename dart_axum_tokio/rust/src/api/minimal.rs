use axum::routing::{get, post};
use flutter_rust_bridge::{frb, DartFnFuture};
use lazy_static::lazy_static;
use simd_json::to_vec;
use std::sync::Arc;
use tokio::runtime::Runtime;

lazy_static! {
    static ref RT: Arc<Runtime> = Arc::new(
        tokio::runtime::Builder::new_multi_thread()
            .worker_threads(4)
            .enable_all()
            .build()
            .unwrap()
    );
}

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(serialize)]
pub async fn rustJsonDecode(mut s: Vec<u8>) -> Result<simd_json::OwnedValue, simd_json::Error> {
    simd_json::to_owned_value(s.as_mut_slice())
}

#[flutter_rust_bridge::frb(serialize)]
pub async fn rustJsonEncode(v: simd_json::OwnedValue) -> Result<Vec<u8>, simd_json::Error> {
    to_vec(&v)
}

#[tokio::main(flavor = "current_thread")]
#[flutter_rust_bridge::frb(serialize)]
pub async fn start_server(
    dart_get_callback: impl (Fn() -> DartFnFuture<Vec<u8>>) + Send + Sync + 'static,
    dart_post_callback: impl (Fn(Vec<u8>) -> DartFnFuture<Vec<u8>>) + Send + Sync + 'static,
) -> bool {
    let get_callback = Arc::new(dart_get_callback);
    let post_callback = Arc::new(dart_post_callback);

    let _ = RT.spawn(async move {
        let address = "0.0.0.0:3000";

        let get_handler = move || async move { get_callback().await };
        let post_handler = move |req: axum::extract::Request| async move {
            let b = axum::body::to_bytes(req.into_body(), usize::MAX)
                .await
                .unwrap();
            post_callback(b.to_vec()).await
        };
        let app = axum::Router::new()
            .route("/", get(get_handler))
            .route("/", post(post_handler));

        println!("Listening on {address}");
        let listener = tokio::net::TcpListener::bind(address).await.unwrap();

        axum::serve(listener, app).await.unwrap();
    });

    return true;
}
