module API
  module Jobs
    class Filter < Cramp::Action
      include API
      include API::Jobs

      before_start :init_job_api,
                   :filter_jobs_by_field

      def start
        render @jobs.to_json
        finish
      end
    end
  end
end
