module API
  module Jobs
    class Kinds < Cramp::Action
      include API
      include API::Jobs

      before_start :init_job_api,
                   :fetch_job_kinds

      def start
        render @kinds.to_json
        finish
      end
    end
  end
end
