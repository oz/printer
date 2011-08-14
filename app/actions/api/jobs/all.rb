module API
  module Jobs
    class All < Cramp::Action
      include API
      include API::Jobs

      before_start :init_job_api,
                   :fetch_all_jobs

      def start
        render @jobs.to_json
        finish
      end
    end
  end
end
