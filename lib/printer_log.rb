# encoding: utf-8
require 'nokogiri'

class PrinterLog

  attr_reader :jobs

  def initialize(file)
    @file    = file
    @doc     = Nokogiri File.read(@file)
    @jobs    = {}
    @threads = []

    # Initialize each job type
    @doc.xpath('//MFP/JobHistoryList')
      .children
      .select { |c| c.class == Nokogiri::XML::Element }
      .each   { |node| @jobs[node.name.downcase] = [] }

    # Parse history for each job type
    @jobs.keys.each { |job_type|
      parse_method = "parse_#{job_type.downcase}_jobs".to_sym
      if self.respond_to?(parse_method)
        @threads << Thread.new { self.send(parse_method) }
      end 
    }
    @threads.each &:join
  end

  # Known types so far...
  # @return Array list of job types we encountered.
  def job_types
    @jobs.keys
  end

  # Parse Printing jobs (Type == 'Print'). Each job is appended to
  # @jobs['Print'].
  #
  # @return Fixnum count of parsed jobs
  def parse_print_jobs
    @doc.xpath('//MFP/JobHistoryList/Print/JobHistory').each { |node|
      @jobs['print'] << self.parse_print_job(node)
    }

    @jobs['print'].size
  end

  # Parse Scan-to-mail jobs (Type == 'Send'). Each job is appended
  # to @jobs['Send']
  #
  # @return Fixnum count of parsed jobs
  def parse_send_jobs
    @doc.xpath('//MFP/JobHistoryList/Send/JobHistory').each { |node|
      @jobs['send'] << self.parse_send_job(node)
    }

    @jobs['send'].size
  end

  protected

  # Parse DateTime nodes into Time instances
  # @param  node Nokogiri::XML::Element
  # @return Time
  #
  # Dates seem to be stored with a minute precision w/ the following pseudo-schema:
  #   <CreateTime>
  #     <Year>2011</Year>
  #     <Month>7</Month>
  #     <Day>15</Day>
  #     <Hour>16</Hour>
  #     <Minute>1</Minute>
  #   </CreateTime>
  def parse_date(node)
    Time.mktime node.at_xpath('Year').text,
                node.at_xpath('Month').text,
                node.at_xpath('Day').text,
                node.at_xpath('Hour').text,
                node.at_xpath('Minute').text
  end

  # Parse a Print job node
  #
  # @param  Nokogiri::XML::Element j
  # @return Hash
  def parse_print_job(j)
    kind       = j.at_xpath("KindOfJob/JobType").text.downcase
    created_at = self.parse_date j.at_xpath('JobTime/CreateTime')
    stopped_at = self.parse_date j.at_xpath('JobTime/EndTime')
    canceled   = j.at_xpath('JobResult/Result').text != 'End'
    name       = if kind == 'print'
                   j.at_xpath('JobCommonMode/JobName').text
                 else
                   'COPY'
                 end

    {
      job_id:     j.at_xpath('JobID').text,
      kind:       kind,
      owner:      j.at_xpath('JobCommonMode/UserName').text,
      name:       name,
      created_at: created_at,
      stopped_at: stopped_at,
      duration:   (stopped_at - created_at).to_i, # in seconds
      canceled:   canceled,
      paper:      j.at_xpath('PaperOutput').text,
      copy_num:   j.at_xpath('JobNumber/CopyNumber').text.to_i,
      doc_num:    j.at_xpath('JobNumber/DocumentNumber').text.to_i
    }
  end

  # Parse a Send job node
  #
  # @param  Nokogiri::XML::Element j
  # @return Hash
  def parse_send_job(j)
    kind   = j.at_xpath("KindOfJob/JobType").text.downcase
    date   = parse_date j.at_xpath('JobTime/CreateTime')
    failed = j.at_xpath('JobResult/Result').text != 'End'

    {
      job_id:     j.at_xpath('JobID').text,
      kind:       kind,
      owner:      j.at_xpath('Destination').text,
      name:       j.at_xpath('JobCommonMode/JobName').text,
      created_at: date,
      failed:     failed,
    }
  end
end
