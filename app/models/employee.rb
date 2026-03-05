class Employee < ApplicationRecord
    has_many :attendances

    def working_days
        attendances.count
    end
      
    def ot_hours
        attendances.sum(&:ot_hours)
    end
      
    def ot_rate
        base_salary / 30 / 8
    end
      
    def ot_pay
        ot_hours * ot_rate
    end

    def tax
        income = base_salary + ot_pay
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
        base_salary + ot_pay - tax
    end
end
