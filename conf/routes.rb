# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(Home)

  # API stuff
  add('/jobs').to(API::Jobs::All)
  add('/jobs/where/:key/:value').to(API::Jobs::Filter)
  add('/job_kinds').to(API::Jobs::Kinds)
end
