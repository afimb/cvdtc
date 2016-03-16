class ValidationService
  attr_reader :reports, :lines, :filenames, :tests, :search, :filter, :count_errors
  attr_accessor :default_view

  def initialize(validation_report, action_report, q = nil)
    @validations = validation_report
    @action_report = action_report
    @search = q && q['search'] ? q['search'].split(',').compact.collect(&:strip).map(&:to_s).map(&:downcase) : nil
    @filter = q && q['filter'] ? q['filter'] : { 'lines': nil, 'status': nil }
    @default_view = :files
    @reports = []
    @lines = []
    @filenames = []
    @tests = []
    @count_errors = { files: {}, lines: {} }
    do_report if @validations
  end

  def do_report
    @validations['validation_report']['tests'].each do |test|
      report = OpenStruct.new
      report.test_id = test['test_id']
      report.error_count = test['error_count']
      report.severity = test['severity']
      report.result = test['result']
      if test['errors']
        test['errors'].each do |error|
          @report_dup = report.dup

          @report_dup.error_id = error['error_id']
          @report_dup.source_label = error['source']['label']
          @report_dup.source_objectid = error['source']['objectid']
          @report_dup.error_value = error['error_value']
          @report_dup.reference_value = error['reference_value']

          if error['target']
            error['target'].each_with_index do |target, index|
              @report_dup.send("target_#{index}_label=", target['label'])
              @report_dup.send("target_#{index}_objectid=", target['objectid'])
            end
          end

          file_infos = error['source']['file']
          parse_files(file_infos)
          line_infos = error['source']['line']
          parse_lines(line_infos)

          next unless parse_search?
          next unless parse_filter?(file_infos)

          if file_infos
            status = @action_report[:files].select{ |datas| datas['name'] == file_infos['filename'] }
            status = status.any? ? status.first['status'] : nil
            @filenames << { name: file_infos['filename'], status: status }
          end

          # TODO - Wait for IEV update
          # if line_infos
          #   status = @action_report[:lines].select{ |datas| datas['name'] == line_infos['    '] }
          #   status = status.any? ? status.first['status'] : nil
          #   @lines << { name: file_infos['      '], status: status }
          # end

          @tests << test['test_id'] if test['test_id'].present?
          @reports << @report_dup
        end
      else
        @reports << report
      end
    end
    clean_datas
  end

  def to_csv
    CSV.generate(headers: true, col_sep: ';') do |csv|
      csv << csv_headers
      send("csv_body_#{default_view}") { |datas| csv << datas }
    end
  end

  private

  def parse_search?
    if @search.present?
      count = @report_dup.to_h.count do |_key, value|
        @search.count { |search_value| value.to_s.downcase =~ /#{search_value}/i } > 0
      end
      return count == @search.count
    end
    true
  end

  def parse_filter?(file_infos)
    if @filter['lines'].present?
      return false unless error['source']['label'].present?
      return false if @filter['lines'] != 'conform_line'
    end
    if @filter['status'].present? && file_infos
      count = @action_report[:files].count{ |datas|
        datas['name'] == file_infos['filename'] && datas['status']&.downcase == @filter['status'].downcase
      }
      return false if count == 0
    end
    true
  end

  def parse_lines(line_infos)
    # TODO - Wait for IEV update
    if line_infos && line_infos.key?('  ')
      @report_dup.linename = line_infos['     ']
      @count_errors[:lines][@report_dup.linename] ||= { error: 0, warning: 0 }
      @count_errors[:lines][@report_dup.linename][get_status(@report_dup)] += 1
    end
  end

  def parse_files(file_infos)
    if file_infos && file_infos.key?('filename')
      @report_dup.filename = file_infos['filename']
      @report_dup.line_number = file_infos['line_number'] if file_infos.key? 'line_number'
      @report_dup.column_number = file_infos['column_number'] if file_infos.key? 'column_number'
      @count_errors[:files][@report_dup.filename] ||= { error: 0, warning: 0 }
      @count_errors[:files][@report_dup.filename][get_status(@report_dup)] += 1
    end
  end

  def csv_headers
    if @default_view == :files
      ['Statut', 'Fichier', 'Ligne/Colonne', 'Code', 'Contrôle', 'Détail de l\'erreur']
    else
      ['Statut', 'Ligne', 'Fichier', 'Ligne/Colonne', 'Code', 'Contrôle', 'Détail de l\'erreur']
    end
  end

  def csv_body_lines
    # TODO - Wait for IEV update
    # @lines.each do |line|
      # reports2 = reports.select{ |r| r.source_label == line[:name] }
      # @filenames.each do |filename|
      #   reports3 = reports2.select{ |r| r.filename == filename[:name] }
      #   reports3.each_with_index do |report, index|
      #     break if index > 10
      #     yield [
      #         I18n.t("compliance_check_result.severities.#{line[:status].downcase}_txt"),
      #         line[:name],
      #         filename[:name],
      #         get_line_column(report),
      #         report.test_id,
      #         I18n.t("validation_report.details.#{report.test_id}"),
      #         I18n.t("validation_report.details.detail_#{report.error_id}", report.to_h)
      #     ]
      #   end
      # end
      # (reports-reports2).each_with_index do |report, index|
      #   break if index > 10
      #   yield [
      #       I18n.t("compliance_check_result.severities.#{line[:status].downcase}_txt"),
      #       line[:name],
      #       '',
      #       '',
      #       report.test_id,
      #       I18n.t("validation_report.details.#{report.test_id}"),
      #       I18n.t("validation_report.details.detail_#{report.error_id}", report.to_h)
      #   ]
      # end
    # end
  end

  def csv_body_files
    @filenames.each do |filename|
      reports2 = reports.select{ |r| r.filename == filename[:name] }
      reports2.each_with_index do |report, index|
        break if index > 10
        yield [
            (filename[:status] ? I18n.t("compliance_check_result.severities.#{filename[:status].downcase}_txt") : ''),
            filename[:name],
            get_line_column(report),
            report.test_id,
            I18n.t("validation_report.details.#{report.test_id}"),
            I18n.t("validation_report.details.detail_#{report.error_id}", report.to_h)
        ]
      end
    end
  end

  def get_line_column(report)
    line_column = []
    if report.line_number.to_i > 0 && report.column_number.to_i > 0
      line_column << "#{I18n.t('report.file.line')} #{report.line_number}"
      line_column << "#{I18n.t('report.file.column')} #{report.column_number}"
    end
    line_column.join(' ')
  end

  def clean_datas
    if @filter['status'].blank? || @filter['status'] == 'success'
      @action_report[:files].each do |file|
        @filenames << { name: file['name'], status: file['status'] }
        @count_errors[:files][file['name']] ||= { error: 0, warning: 0 }
      end
    end
    if @filenames.present?
      @filenames.compact.reject! { |f| f[:name].blank? }
      @filenames.uniq! { |f| f[:name] }
      @filenames.sort_by! { |a| a[:name] }
    end
    if @filter['lines'].blank? || @filter['lines'] == 'conform_line'
      @action_report[:lines].each do |line|
        @lines << { name: line['name'], status: line['status'] }
        @count_errors[:lines][line['name']] ||= { error: 0, warning: 0 }
      end
    end
    if @lines.present?
      @lines.compact.reject! { |f| f[:name].blank? }
      @lines.uniq! { |f| f[:name] }
      @lines.sort_by! { |a| a[:name] }
    end
    @tests = @tests.compact.reject(&:blank?).uniq.sort if @tests.present?
  end

  def get_status(report)
    severity = report.severity.downcase.to_sym
    result = report.result.downcase.to_sym
    return if result == :ok
    severity
  end
end
