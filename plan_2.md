# PLAN 2 — HOÀN THIỆN & SỬA LỖI GYMTRACK

## ROLE

Bạn là coding agent (Senior Flutter Developer). Dự án **GymTrack** đã có bản đầu tiên theo `plan.md`. Nhiệm vụ của plan này là **sửa các điểm còn thiếu hoặc sai so với plan.md**, không viết lại từ đầu.

## QUY TẮC CHUNG

1. Đọc `plan.md` trước, rồi đọc code hiện tại của phần sắp sửa. Không phá kiến trúc đang có (`core/`, `data/`, `domain/`, `features/`, `routing/`).
2. Làm **từng task một**, theo thứ tự. Sau mỗi task chạy `dart format .`, `flutter analyze`, `flutter test`. Chỉ sang task sau khi 3 lệnh này sạch.
3. Không để business logic hoặc SQL trong widget. Thao tác dữ liệu đi qua repository.
4. Nếu đổi schema Drift: tăng `schemaVersion`, viết `onUpgrade`, chạy `dart run build_runner build --delete-conflicting-outputs`. Không được làm mất dữ liệu người dùng đang có.
5. Không tuyên bố hoàn thành nếu chưa chạy kiểm tra thật. Nếu môi trường không chạy được (không có Flutter, không có thiết bị), nói rõ phần nào chưa kiểm tra.
6. Không sửa thư mục `.dart_tool/`, `build/`, các file `*.g.dart` bằng tay.

## HIỆN TRẠNG (đã xác minh bằng đọc code)

Đã có và đúng hướng: Drift + SQLite persistent, seed một lần (`seedDatabaseIfEmpty`), foreign keys bật, 5 tab điều hướng, repository pattern, Riverpod, rest timer, progress/chart lấy từ DB, body tracking, export/import JSON, snapshot `planName`/`dayName`/`exerciseName` trong session, `workoutDayId` dùng `setNull` khi xoá plan.

Còn thiếu hoặc sai: xem các task bên dưới.

---

## TASK 1 — [P0] Xoá custom exercise đang làm mất lịch sử

**Vấn đề:** `ExerciseSessions.exerciseId` và `WorkoutExercises.exerciseId` đều `onDelete: cascade`. Khi xoá một custom exercise ở `exercise_library_screen.dart`, toàn bộ ExerciseSession và WorkoutSet của bài đó trong lịch sử bị xoá theo. Điều này vi phạm plan.md mục 5 và 14 ("không xoá lịch sử").

**Cần làm:**
- Đổi `ExerciseSessions.exerciseId` thành nullable + `onDelete: setNull` (đã có `exerciseName` snapshot để vẫn hiển thị tên).
- Chuyển sang **soft delete** cho Exercise: thêm cột `isArchived` (bool, default false). Thư viện bài tập và picker chỉ hiện bài chưa archive; lịch sử vẫn hiển thị bình thường.
- Viết migration v1 → v2.
- Cập nhật UI xác nhận: nói rõ "bài tập sẽ bị ẩn, lịch sử vẫn giữ".

**Nghiệm thu:** test mới: tạo custom exercise → ghi 1 workout → xoá exercise → history và progress của workout đó vẫn còn, tên bài vẫn hiển thị.

## TASK 2 — [P0] Đơn vị kg/lb chỉ đổi nhãn, không quy đổi

**Vấn đề:** `Formatters.formatWeight` chỉ ghép chuỗi đơn vị. Khi người dùng chuyển sang lb, 60 kg hiển thị thành "60 lb" (sai giá trị). Volume cũng chỉ đổi nhãn. `Calculator.kgToLb/lbToKg` có sẵn nhưng không được dùng.

**Cần làm:**
- Quy ước: **DB luôn lưu kg**. UI quy đổi khi hiển thị và khi nhập.
- Áp dụng cho: active workout (nhập và hiển thị set), history, summary, progress/chart, PR, body weight, volume.
- Làm tròn hiển thị hợp lý (1 chữ số thập phân).
- Export/import JSON luôn dùng kg.

**Nghiệm thu:** unit test quy đổi hai chiều; nhập 100 lb → lưu ~45.36 kg → hiển thị lại 100 lb. Đổi đơn vị không làm đổi dữ liệu gốc.

## TASK 3 — [P0] Notification nhắc lịch tập chưa hoạt động

**Vấn đề:** Settings lưu giờ/ngày nhắc nhưng `NotificationService` chỉ có `show()` tức thì, **không có lịch (`zonedSchedule`)** nên reminder không bao giờ tự bắn. `AndroidManifest.xml` chưa khai báo quyền nào (`POST_NOTIFICATIONS`, boot receiver…). `pubspec.yaml` chưa có `timezone`.

**Cần làm:**
- Thêm `timezone` (+ `flutter_timezone` nếu cần) và khởi tạo timezone.
- Implement `scheduleWorkoutReminders(days, hour, minute)` dùng `zonedSchedule` lặp hàng tuần, mỗi ngày đã chọn một notification id riêng; `cancelWorkoutReminders()` khi tắt.
- Gọi lại schedule mỗi khi bật/tắt, đổi giờ, đổi ngày, và khi app khởi động.
- Manifest: thêm `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, khai báo receiver của `flutter_local_notifications` để lịch sống sau khi khởi động lại máy. Dùng chế độ inexact trừ khi có lý do xin `SCHEDULE_EXACT_ALARM`.
- Nội dung: "Time to workout 💪".

**Nghiệm thu:** build release, bật reminder, đặt giờ gần hiện tại → nhận notification khi app đã đóng. Ghi rõ nếu chỉ kiểm tra được trên emulator.

## TASK 4 — [P1] Rest timer không chạy đúng khi app ở nền

**Vấn đề:** `RestTimerNotifier` dùng `Timer.periodic` đếm lùi theo tick. Khi app vào nền hoặc màn hình tắt, Dart timer bị tạm dừng nên timer sai và thông báo "hết giờ nghỉ" không bắn đúng lúc (plan.md mục 12).

**Cần làm:**
- Lưu **thời điểm kết thúc tuyệt đối** (`endAt`); mỗi tick tính `remaining = endAt - now`. Khi app quay lại foreground, tính lại từ `endAt`.
- Khi bắt đầu timer, lên lịch một local notification (`zonedSchedule`) tại `endAt`; huỷ khi Skip hoặc kết thúc sớm; `+30 sec` thì dời lịch.
- Dùng chung hạ tầng timezone của Task 3.

**Nghiệm thu:** bắt đầu timer 30s, khoá màn hình → nhận notification đúng giờ; mở lại app thấy thời gian còn lại chính xác.

## TASK 5 — [P1] Chỉnh sửa Workout Plan còn thiếu

**Vấn đề:** plan.md mục 8 yêu cầu rename plan, rename day, reorder exercise. Code hiện chưa có: `plan_detail_screen.dart` chỉ thêm/xoá; repository chưa có hàm reorder và chưa có update cho `WorkoutExercise`.

**Cần làm:**
- Rename plan và rename day (dialog sửa tên, validate không rỗng).
- Sửa tham số của exercise trong plan: `targetSets`, `targetMinReps`, `targetMaxReps`, `restSeconds`.
- Reorder exercise bằng `ReorderableListView`; lưu `orderIndex` trong một transaction. Cân nhắc reorder day tương tự.
- Thêm các hàm tương ứng vào `WorkoutRepository` + `AppDatabase`.
- Đảm bảo sửa plan **không** thay đổi dữ liệu các session cũ.

**Nghiệm thu:** unit test reorder giữ đúng `orderIndex`; test sửa plan xong history cũ không đổi.

## TASK 6 — [P1] `createWorkoutSession` tạo cố định 3 set, bỏ qua `targetSets`

**Vấn đề:** khi bắt đầu từ plan, code luôn tạo 3 set và đặt sẵn weight/reps theo buổi trước, không dùng `targetSets`, `targetMinReps` của plan. Plan.md mục 11 cũng yêu cầu previous performance chỉ để tham khảo và không tự ghi đè.

**Cần làm:**
- Số set khởi tạo = `targetSets` của `WorkoutExercise` (mặc định 3 khi bắt đầu workout tự do).
- Tách rõ: dòng **"Previous"** hiển thị hiệu suất lần trước (chỉ đọc); ô nhập set mới có thể gợi ý (placeholder/hint) thay vì điền sẵn giá trị thật. Nếu muốn giữ điền sẵn, thêm công tắc trong Settings, mặc định **tắt**.
- Rest timer dùng `restSeconds` của exercise trong plan, nếu không có thì dùng mặc định trong Settings.

**Nghiệm thu:** plan có bài 4 set → session có đúng 4 set; set chưa tick `completed` không bị tính vào volume/PR.

## TASK 7 — [P1] Thiếu integration test và widget test theo plan

**Vấn đề:** plan.md mục 26 yêu cầu integration test cho flow Create plan → Start → Add exercise → Add sets → Finish → History. Hiện chưa có thư mục `integration_test/`. Widget test chưa có Workout/Add Set.

**Cần làm:**
- Thêm `integration_test/app_flow_test.dart` và `integration_test` vào `dev_dependencies`.
- Thêm widget test cho màn hình Active Workout (Add Set, tick completed, validate weight/reps).
- Thêm test cho các task 1, 2, 5, 6 ở trên.

**Nghiệm thu:** `flutter test` pass; nếu có emulator, `flutter test integration_test` pass.

## TASK 8 — [P2] Dọn kiến trúc & chất lượng

- `AppDatabase` (~900 dòng) đang chứa toàn bộ truy vấn. Tách thành các DAO (`daos/exercise_dao.dart`, `workout_dao.dart`, `body_dao.dart`) đúng cấu trúc plan.md mục 3, giữ nguyên hành vi. Làm sau cùng và chạy lại toàn bộ test.
- `settings_screen.dart` (~400 dòng) và `active_workout_screen.dart` (~490 dòng): tách widget con có thể tái sử dụng (plan.md mục 27: "không giant widgets").
- Thay `withOpacity` (deprecated) bằng `withValues(alpha: ...)`.
- Xử lý lỗi: các `catch (_) {}` trong `NotificationService` đang nuốt lỗi im lặng; ít nhất log lại trong debug.
- `import` JSON: kiểm tra `schemaVersion` của file backup, báo lỗi dễ hiểu khi file hỏng hoặc sai phiên bản, và **không làm hỏng DB hiện tại nếu import thất bại** (bọc trong transaction, rollback khi lỗi).
- Cập nhật `README.md` (đang là mặc định của Flutter): mô tả app, cách chạy, cách build APK.

## TASK 9 — [P2] Dọn repo

- `.gitignore` cần loại `.dart_tool/`, `build/`, `android/.kotlin/`, `android/local.properties`. Hiện zip chứa ~440 MB file build.
- Không đưa APK hoặc thư mục build vào git.

---

## THỨ TỰ THỰC HIỆN

1. Task 1 → 2 → 3 (P0, ảnh hưởng dữ liệu và tính năng chính)
2. Task 4 → 5 → 6 → 7 (P1)
3. Task 8 → 9 (P2)

## ĐỊNH NGHĨA HOÀN THÀNH

Mỗi task chỉ xong khi: code đã sửa, test liên quan đã viết và pass, `flutter analyze` không có lỗi, và không có hồi quy ở các chức năng cũ (đặc biệt: dữ liệu vẫn còn sau khi đóng/mở app, app vẫn chạy offline).

## BÁO CÁO CUỐI MỖI TASK

1. File đã tạo/sửa.
2. Thay đổi schema (nếu có) và migration.
3. Test đã chạy + kết quả thật của `flutter analyze` / `flutter test`.
4. Phần nào **chưa kiểm tra được** và vì sao.
5. Việc còn tồn đọng.
