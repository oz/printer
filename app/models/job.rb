# encoding: utf-8

class Job
  include Mongoid::Document

  # FIXME
  #  - add indexes (job_id, created_at, ...)
  #  - declare fields for readability and validations

  default_scope order_by(job_id: 'asc')

  scope :created_before, proc { |date| where(:created_at.lt => date) if date }
  scope :created_after,  proc { |date| where(:created_at.gt => date) if date }

  cattr_accessor :per_page
  self.per_page = 50

  # Import an Printer loug file.
  #
  # @see    PrinterLog
  # @param  [ String ] file printer log file (XML)
  # @return [ NilClass ]
  def self.import_file!(file)
    log = PrinterLog.new file
    log.job_types.each { |type|
      log.jobs[type].each { |log| save_log log }
    }
  end

  protected

  # Create or update the log entry
  #
  # @see    PrinterLog
  # @param  [ Hash ] log_entry
  # @return [ True, False ] cf. Mongoid
  def self.save_log(log_entry)
    exist = Job.where(job_id: log_entry[:job_id]).count > 0
    Job.new(log_entry).save! unless exist
  end
end
