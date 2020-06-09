Put your application inside `/app`, and do eg:

`docker build -t iisexpress-test:v0.2 .`

Then start the container:

`docker run -p 80:80 iisexpress-test:v0.2`

Shouldn't be more to it than that!