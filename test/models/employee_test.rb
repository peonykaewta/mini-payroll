require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  # --- working_days ---
  test "working_days is 0 when no attendances" do
    employee = Employee.create!(name: "No Days", position: "Dev", base_salary: 30_000)
    assert_equal 0, employee.working_days
  end

  test "working_days counts attendances" do
    employee = Employee.create!(name: "Tester", position: "Dev", base_salary: 30_000)

    2.times do |i|
      Attendance.create!(
        employee: employee,
        check_in: Time.zone.local(2026, 3, 5 + i, 9, 0, 0),
        check_out: Time.zone.local(2026, 3, 5 + i, 17, 0, 0)
      )
    end

    assert_equal 2, employee.working_days
  end

  # --- ot_hours ---
  test "ot_hours is 0 when no attendances" do
    employee = Employee.create!(name: "No OT", position: "Dev", base_salary: 30_000)
    assert_equal 0, employee.ot_hours
  end

  test "ot_hours sums up ot_hours from attendances" do
    employee = Employee.create!(name: "OT Tester", position: "Dev", base_salary: 30_000)

    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 18, 0, 0)
    )

    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 6, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 6, 19, 0, 0)
    )

    assert_in_delta 3.0, employee.ot_hours, 0.001
  end

  # --- ot_rate ---
  test "ot_rate is 0 when base_salary is nil" do
    employee = Employee.new(name: "No Salary", position: "Dev", base_salary: nil)
    assert_equal 0, employee.ot_rate
  end

  test "ot_rate is 0 when base_salary is 0" do
    employee = Employee.new(name: "Zero Salary", position: "Dev", base_salary: 0)
    assert_equal 0, employee.ot_rate
  end

  test "ot_rate is base salary divided by 30 days and 8 hours" do
    employee = Employee.new(name: "Rate Tester", position: "Dev", base_salary: 30_000)

    expected_rate = 30_000.0 / 30.0 / 8.0
    assert_in_delta expected_rate, employee.ot_rate, 0.001
  end

  # --- ot_pay ---
  test "ot_pay is 0 when no attendances" do
    employee = Employee.create!(name: "No Pay", position: "Dev", base_salary: 30_000)
    assert_equal 0, employee.ot_pay
  end

  test "ot_pay equals ot_hours times ot_rate when has attendances" do
    employee = Employee.create!(name: "OT Pay", position: "Dev", base_salary: 30_000)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 19, 0, 0)
    )
    expected = employee.ot_hours * employee.ot_rate
    assert_in_delta expected, employee.ot_pay, 0.001
  end

  # --- tax ---
  test "tax is 0 when working_days is 0" do
    employee = Employee.create!(name: "No Work", position: "Dev", base_salary: 50_000)
    assert_equal 0, employee.working_days
    assert_equal 0, employee.tax
  end

  test "tax is 0 when income is 0" do
    employee = Employee.create!(name: "Zero Income", position: "Dev", base_salary: 0)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 17, 0, 0)
    )
    assert_equal 0, employee.tax
  end

  test "tax is 0 when income not over 30_000" do
    employee = Employee.create!(name: "Low", position: "Dev", base_salary: 25_000)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 17, 0, 0)
    )
    assert_equal 0, employee.tax
  end

  test "tax uses 5% bracket for income over 30_000" do
    employee = Employee.create!(name: "Mid", position: "Dev", base_salary: 40_000)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 17, 0, 0)
    )
    # income 40_000 -> (40_000 - 30_000) * 0.05 = 500
    assert_in_delta 500.0, employee.tax, 0.001
  end

  test "tax is calculated with progressive brackets over 50k and 30k" do
    employee = Employee.create!(name: "High", position: "Dev", base_salary: 60_000)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 17, 0, 0)
    )
    # income 60_000: (60_000-50_000)*0.10 + (50_000-30_000)*0.05 = 1_000 + 1_000 = 2_000
    assert_in_delta 2_000.0, employee.tax, 0.001
  end

  # --- net_pay ---
  test "net_pay is 0 when working_days is 0" do
    employee = Employee.create!(name: "No Work", position: "Dev", base_salary: 30_000)
    assert_equal 0, employee.working_days
    assert_equal 0, employee.net_pay
  end

  test "net_pay equals base salary plus ot_pay minus tax" do
    employee = Employee.create!(name: "Net Tester", position: "Dev", base_salary: 30_000)

    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 19, 0, 0)
    )

    expected_net = employee.base_salary + employee.ot_pay - employee.tax
    assert_in_delta expected_net, employee.net_pay, 0.001
  end

  test "net_pay is 0 when base_salary 0 with one working day" do
    employee = Employee.create!(name: "Zero Salary", position: "Dev", base_salary: 0)
    Attendance.create!(
      employee: employee,
      check_in: Time.zone.local(2026, 3, 5, 9, 0, 0),
      check_out: Time.zone.local(2026, 3, 5, 17, 0, 0)
    )
    employee.reload
    assert_equal 0, employee.net_pay
  end
end
