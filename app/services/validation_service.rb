class ValidationService
  attr_reader :reports, :lines, :filenames, :tests, :search_for, :count_errors_by_filename

  def initialize(validation_report, search_for = nil)
    @validations = validation_report
    @search_for = search_for ? search_for.split(',').compact.collect(&:strip).map(&:to_s).map(&:downcase) : nil
    @reports = []
    @lines = []
    @filenames = []
    @tests = []
    @count_errors_by_filename = {}
    do_report if @validations
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
          if file_infos && file_infos.key?('filename')
            report_dup.filename = file_infos['filename']
            report_dup.line_number = file_infos['line_number'] if file_infos.key? 'line_number'
            report_dup.column_number = file_infos['column_number'] if file_infos.key? 'column_number'
            @count_errors_by_filename[report_dup.filename] ||= 0
            @count_errors_by_filename[report_dup.filename] += 1
          end
          if error['target']
            error['target'].each_with_index do |target, index|
              report_dup.send("target_#{index}_label=", target['label'])
              report_dup.send("target_#{index}_objectid=", target['objectid'])
            end
          end
          pass = true
          if @search_for.present?
            count = report_dup.to_h.count do |_key, value|
              @search_for.count { |search_value| value.to_s.downcase =~ /#{search_value}/ } > 0
            end
            pass = count == @search_for.count ? true : false
          end
          next unless pass
          @lines << { name: error['source']['label'] }
          @filenames << { status: report_dup.status, name: file_infos['filename'] } if file_infos
          @tests << test['test_id']
          @reports << report_dup
        end
      else
        @reports << report
      end
    end
    clean_datas
  end

  private

  def clean_datas
    if @filenames.present?
      @filenames.compact.reject! { |f| f[:name].blank? }
      @filenames.uniq! { |f| f[:name] }
      @filenames.sort_by! { |a| a[:name] }
    end
    if @lines.present?
      @lines.compact.reject! { |f| f[:name].blank? }
      @lines.uniq! { |f| f[:name] }
      @lines.sort_by! { |a| a[:name] }
    end
    @tests = @tests.compact.reject(&:blank?).uniq.sort if @tests.present?
  end

  def class_name(report)
    severity = report.severity.downcase.to_sym
    result = report.result.downcase.to_sym
    return 'check' if result == :ok
    severity == :warning ? 'alert' : 'remove'
  end
end
