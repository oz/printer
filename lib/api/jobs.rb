# encoding: utf-8
module API
  module Jobs
    # Initialize job list and headers
    def init_job_api
      @jobs    = []
      @kinds   = []
      @headers = {}

      # Paginate per 100000 jobs per default, ie. get everything once and for
      # all. Feel free to specfify per_page=10 when debugging.
      Job.per_page = params[:per_page] || 10000

      yield
    end

    # This API responds to JSON requests...
    def respond_with
      [200, {'Content-Type' => 'application/json'}.merge(@headers)]
    end

    # Load all jobs
    def fetch_all_jobs
      @jobs = paginate(filter_by_dates(Job.all))
      yield
    end

    # Filter jobs by any field / value combination
    def filter_jobs_by_field
      key, value = params[:key].to_sym, params[:value]
      @jobs = paginate(filter_by_dates(Job.where(key => value)))
      yield
    end

    # List the known job kinds
    def fetch_job_kinds
      # FIXME Use mongodb's map-reduce with Job.map_reduce.
      @kinds = Job.all.map(&:kind).sort.uniq
      yield
    end
  end
end
