# encoding: utf-8

class Printer < Sinatra::Base
  register Sinatra::Async

  set :root, PRINTER_ROOT + '/app'
  set :public, PRINTER_ROOT + '/app/static'

  ##
  # Homepage
  aget '/' do
    body haml(:index)
  end

  # --------------------------------------------------------------------------
  # JSON methods

  before do
    # Parse date params
    params[:before] = DateTime.parse(params[:before]).to_time if params[:before]
    params[:after]  = DateTime.parse(params[:after]).to_time  if params[:after]
  end

  provides :json

  ##
  # List all jobs
  aget '/jobs' do
    jobs = Job.all
    jobs = filter_by_dates(jobs)
    body paginate(jobs).to_json
  end

  ##
  # List known job types, also known as their kind.
  aget '/job_kinds' do
    # FIXME there is map/reduce within MongoDB: Use Job.map_reduce.
    body Job.all.map(&:kind).sort.uniq.to_json
    #body %w(copy print scan).to_json
  end

  ##
  # Filter jobs on a given field/value.  This is rather dangerous and
  # ill-advised security-wise, but the app is still at pre-alpha stage and
  # should not be a public API either...  The correct way is to implement this
  # as a private method, and declare public APIs around it. -- oz
  #
  # GET /jobs/where/kind/print
  # GET /jobs/where/owner/oz
  # GET /jobs/where/some_field/some_value
  aget '/jobs/where/:key/:value' do |key, value|
    jobs = Job.where(key.to_sym => value)
    jobs = filter_by_dates(jobs)
    body paginate(jobs).to_json
  end

  protected

  # Paginate a list of objects from Mongoid, and add pagination headers.
  #
  # @param [#total_pages, #total_entries, #paginate, #klass, Mongoid::Criteria]
  # @return [ Array ]
  def paginate(list)
    list = list.paginate page:     params[:page],
                         per_page: list.klass.per_page
    headers 'X-Total-Pages'   => list.total_pages.to_s,
            'X-Total-Entries' => list.total_entries.to_s
    list
  end

  # Apply before/after date filters to a collection (Mongoid::Criteria), when
  # the before and/or after params are present.
  #
  # @param [#created_before, #created_after]
  # @return Mongoid::Criteria
  def filter_by_dates(list)
    list = list.created_after(params[:after])   if params[:after]
    list = list.created_before(params[:before]) if params[:before]
    list
  end
end
