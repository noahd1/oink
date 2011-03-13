class FakeApplicationController

  def initialize(logger = Logger.new(StringIO.new))
    @logger = logger
  end

  class << self
    attr_accessor :around_filters

    def around_filter method
      (@around_filters ||= []) << method
    end
  end

  def index
    run_around_filters
  end

  def logger
    @logger
  end

  protected
  def run_around_filters
    self.class.around_filters.each { |filter| self.send(filter) { perform_action } }
  end

  def perform_action
  end
end