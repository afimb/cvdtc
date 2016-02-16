class ValidationService
  attr_reader :reports, :lines, :filenames, :tests, :search_for

  def initialize(validation_report, search_for=nil)
    @validations = validation_report
    @search_for = search_for ? search_for.split(',').compact.collect(&:strip).map(&:to_s).map(&:downcase) : nil
    @reports = []
    @lines = []
    @filenames = []
    @tests = []
    do_report
  end

  def do_report
    @validations['validation_report']['tests'].each do |test|
      report = OpenStruct.new
      report.test_id = test['test_id']
      report.error_count = test['error_count']
      report.severity = test['severity']
      report.result = test['result']
      report.status = class_name(report)
      if test['errors']
        test['errors'].each do |error|
          report_dup = report.dup
          report_dup.error_id = error['error_id']
          report_dup.source_label = error['source']['label']
          report_dup.source_objectid = error['source']['objectid']
          report_dup.error_value = error['error_value']
          report_dup.reference_value = error['reference_value']
          file_infos = error['source']['file']
          if file_infos && file_infos.has_key?('filename')
            report_dup.filename = file_infos['filename']
            report_dup.line_number = file_infos['line_number'] if file_infos.has_key? 'line_number'
            report_dup.column_number = file_infos['column_number'] if file_infos.has_key? 'column_number'
          end
          if error['target']
            error['target'].each_with_index do |target, index|
              report_dup.send("target_#{index}_label=", target['label'])
              report_dup.send("target_#{index}_objectid=", target['objectid'])
            end
            pass = true
            if @search_for.present?
              pass = report_dup.to_h.select{ |key, value|
                @search_for.select{ |search_value|
                  value.to_s.downcase =~ /#{search_value}/ }.present? }.count == @search_for.count ? true : false
            end
            if pass
              @lines << error['source']['label']
              @filenames << file_infos['filename'] if file_infos
              @tests << test['test_id']
              @reports << report_dup
            end
          end
        end
      else
        @reports << report
      end
    end
    @lines = @lines.compact.reject { |c| c.blank? }.uniq.sort
    @filenames = @filenames.compact.reject { |c| c.blank? }.uniq.sort
    @tests = @tests.compact.reject { |c| c.blank? }.uniq.sort
  end

  private

  def class_name(report)
    severity = report.severity.downcase.to_sym
    result = report.result.downcase.to_sym
    return 'check' if result == :ok
    severity == :warning ? 'alert' : 'error'
  end
end
