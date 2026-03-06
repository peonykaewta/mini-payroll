class Employee < ApplicationRecord
    has_many :attendances, dependent: :destroy

    def working_days
        attendances.count
    end

    def ot_hours
        attendances.sum { |a| a.ot_hours.to_f }
    end

    def ot_rate
        return 0 if base_salary.nil? || base_salary.zero?
        base_salary / 30.0 / 8.0
    end

    def ot_pay
        (ot_hours || 0).to_f * ot_rate
    end

    def tax
        return 0 if working_days.zero?
        income = (base_salary || 0) + (ot_pay || 0)
        return 0 if income.nil? || income <= 0
        tax = 0

        if income > 50000
          tax += (income - 50000) * 0.10
          income = 50000
        end

        if income > 30000
          tax += (income - 30000) * 0.05
        end

        tax
    end

    def net_pay
        return 0 if working_days.zero?
        (base_salary || 0) + (ot_pay || 0) - (tax || 0)
    end
end
