# encoding: utf-8
module API

  ##
  # Paginate a list of objects from Mongoid, and set pagination headers.
  #
  # @param  [ Mongoid::Criteria ]
  # @return [ Array ]
  def paginate(list)
    total_count = list.count
    total_pages = (total_count / list.klass.per_page.to_f).ceil
    skip        = list.klass.per_page * get_page

    @headers.merge! 'X-Total-Pages'   => total_pages.to_s,
                    'X-Total-Entries' => total_count.to_s

    list.skip(skip).limit(list.klass.per_page)
  end

  ##
  # Apply before/after date filters to a collection (Mongoid::Criteria), when
  # the before and/or after params are present.
  #
  # @param [#created_before, #created_after]
  # @return Mongoid::Criteria
  def filter_by_dates(list)
    format_date_params

    list = list.created_after(params[:after])   if params[:after]
    list = list.created_before(params[:before]) if params[:before]
    list
  end

  private

  ##
  # Check (min) boundaries of params[:page]
  #
  # @return [Fixnum, Bignum]
  def get_page
    page = (params[:page].to_i || 1) - 1
    page = 0 unless page >= 0

    page
  end

  ## 
  # Parse date params, and update params Hash accordingly
  def format_date_params
    params[:before] = DateTime.parse(params[:before]).to_time if params[:before]
    params[:after]  = DateTime.parse(params[:after]).to_time  if params[:after]
  end
end
