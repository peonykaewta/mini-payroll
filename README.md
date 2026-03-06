# Mini Payroll System

ระบบคำนวณเงินเดือนขนาดเล็ก สร้างด้วย Ruby on Rails

## Features

- **Employee CRUD** — จัดการข้อมูลพนักงาน (เพิ่ม/แก้ไข/ลบ/ดู)
- **Time Attendance** — บันทึกเวลาเข้า-ออกงาน
- **OT Calculation** — คำนวณค่าล่วงเวลา
- **Payroll Calculation** — คำนวณเงินเดือน
- **Progressive Tax** — คำนวณภาษีแบบขั้นบันได

## Tech Stack

- **Ruby on Rails** ~> 8.1.2
- **PostgreSQL**
- Hotwire (Turbo + Stimulus)

## Prerequisites

- Ruby 3.x
- PostgreSQL
- Bundler

## Setup

```bash
# Clone และเข้าโฟลเดอร์โปรเจกต์
cd mini-payroll

# ติดตั้ง gems
bundle install

# สร้างและ migrate database
bin/rails db:create db:migrate

# (Optional) โหลดข้อมูลตัวอย่าง
bin/rails db:seed
```

## Running the App

```bash
# Start เซิร์ฟเวอร์
bin/rails server
```

เปิดเบราว์เซอร์ที่ [http://localhost:3000](http://localhost:3000)

## Routes

- `/employees` — จัดการพนักงาน
- `/attendances` — บันทึกการเข้างาน

## Running Tests

```bash
bin/rails test
```

---

## Scope ที่ทำ

### สิ่งที่ทำตาม requirement แล้ว

- **Employee CRUD** — ครบทั้งสร้าง/อ่าน/แก้ไข/ลบ พร้อมฟอร์มและ validation
- **Time Attendance** — บันทึก check-in / check-out ต่อพนักงาน มี validation ให้ check-out หลัง check-in และไม่ซ้ำวันต่อคน
- **OT Calculation** — คำนวณชั่วโมง OT (เกิน 8 ชม./วัน), อัตราค่า OT จาก base salary, และ OT pay
- **Payroll Calculation** — คำนวณเงินเดือนสุทธิ (base + OT - ภาษี) แสดงในหน้าแสดงรายละเอียดพนักงาน
- **Progressive Tax** — คำนวณภาษีแบบขั้นบันได (เช่น 0–30k, 30k–50k 5%, เกิน 50k 10%)

### สิ่งที่ทำเพิ่มเติมจาก requirement

- หน้า **Employee show** แสดง Payroll summary (working days, OT hours, OT pay, Tax, Net pay) และตารางประวัติการเข้างาน
- **Validation** ใน Attendance (check_out ต้องหลัง check_in, check_in ไม่ซ้ำต่อพนักงานต่อวัน)
- **Unit tests** สำหรับโมเดล Employee และ Attendance

### สิ่งที่ทำเพิ่มเติมได้ (แนวทางต่อยอด)

- รายงานสรุปเงินเดือนทั้งบริษัท หรือ export เป็น PDF/Excel
- กำหนด **pay period** (ช่วงคำนวณเงินเดือน เช่น รายเดือน) และกรอง attendances ตามช่วง
- การหักอื่นๆ เช่น ประกันสังคม, กองทุนสำรองเลี้ยงชีพ
- **Authentication / Authorization** (login, สิทธิ์การเข้าถึง)
- ตั้งค่า **อัตรา OT** แยกจาก base (เช่น 1.5x ในวันธรรมดา, 2x ในวันหยุด)
- ตั้งค่าขั้นภาษีและอัตราภาษีแบบ config หรือจากฐานข้อมูล

---

## AI

### AI tools ที่ใช้

| Tool | ใช้ในส่วนไหนบ้าง |
|------|-------------------|
| **Cursor (AI Assistant)** | ช่วยเขียน/แก้ code ในส่วนของ syntax และ UI design, อัปเดต README, แนะนำโครงสร้างและ best practices |
| **ChatGPT** | list step การติดตั้ง ruby on rails |
