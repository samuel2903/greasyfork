class ScriptReport < ApplicationRecord
  belongs_to :script
  belongs_to :reference_script, class_name: 'Script', optional: true
  belongs_to :reporter, class_name: 'User', optional: true

  scope :unresolved, -> { where(resolved: false).joins(:script).merge(Script.not_deleted) }
  scope :unresolved_old, -> { unresolved.where(['script_reports.report_type = ? OR script_reports.created_at < ?', TYPE_MALWARE, 3.days.ago]) }
  
  validates :details, presence: true
  validates :reference_script, presence: true, if: ->(sr) { sr.unauthorized_code? }

  TYPE_UNAUTHORIZED_CODE = 'unauthorized_code'
  TYPE_MALWARE = 'malware'

  def dismissed?
    resolved? && !script.locked?
  end

  def upheld?
    resolved? && script.locked?
  end

  def unauthorized_code?
    report_type == TYPE_UNAUTHORIZED_CODE
  end
end
