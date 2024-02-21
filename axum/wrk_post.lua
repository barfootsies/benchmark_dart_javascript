wrk.method = "POST"
wrk.headers["Content-Type"] = "application/json"

file = io.open("../testdata/posts.json", "rb")
wrk.body = file:read("*a")
