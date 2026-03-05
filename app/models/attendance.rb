class Attendance < ApplicationRecord
  belongs_to :employee

  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :check_in, uniqueness: { scope: :employee_id }

  validate :checkout_after_checkin

  def checkout_after_checkin
    return if check_out.nil? || check_in.nil?

    if check_out <= check_in
      errors.add(:check_out, "must be after check in")
    end
  end

  def working_hours
    return 0 if check_out.nil?
    (check_out - check_in) / 3600
  end
  
  def ot_hours
    hours = working_hours
    hours > 8 ? hours - 8 : 0
  end
end