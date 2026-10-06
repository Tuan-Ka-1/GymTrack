# PLAN 3 — NÂNG CẤP GYMTRACK

Mở rộng thư viện bài tập, thêm đa ngôn ngữ (English / Tiếng Việt), hình minh họa bài tập, đồng hồ bấm giờ. Giữ kiến trúc offline-first, **không mất dữ liệu người dùng**.

---

## 0. ĐIỀU KIỆN TIÊN QUYẾT

**Plan 3 chỉ bắt đầu sau khi xong Task 1, 2, 3 của `plan_2.md`** (P0). Lý do:

- Task 1 của plan_2 sửa khoá ngoại và thêm soft-delete cho Exercise. Plan 3 thêm nhiều cột vào đúng bảng `Exercises`. Hai thay đổi này phải nằm trong chuỗi migration thống nhất (v1→v2 của plan_2, rồi v2→v3 của plan này), không được viết chồng chéo.
- Task 2 (kg/lb) và Task 3 (notification) ảnh hưởng tới localization và Settings.

Nếu plan_2 chưa xong, dừng và báo cáo.

## 1. HIỆN TRẠNG ĐÃ AUDIT (thay cho Phase 0 cũ)

Các điều dưới đây đã được xác minh bằng đọc code. Agent chỉ cần **kiểm tra nhanh lại** (chạy `flutter analyze`, `flutter test`, mở các file nêu tên), không cần audit lại toàn bộ.

- Stack: Flutter, Riverpod, Drift/SQLite (`schemaVersion` hiện là 1, chưa có `onUpgrade`), go_router, `shared_preferences` cho settings, `intl` có sẵn.
- **Chưa có localization nào.** Toàn bộ chuỗi UI là tiếng Anh viết thẳng trong widget. `Formatters` có chuỗi validation tĩnh (không có `context`). `NotificationService` có chuỗi thông báo không có `context`.
- Bảng `Exercises` hiện có: `id, name, muscleGroup, equipment, exerciseType, description, isCustom, createdAt, updatedAt`. **Chưa có** ảnh, hướng dẫn, tips, cơ phụ, khoá định danh ổn định.
- `muscleGroup` và `equipment` đang lưu là **chuỗi tiếng Anh tự do**, không phải enum/khoá.
- Seed nằm trong `seed_data.dart` (hard-code trong Dart) và `AppDatabase.seedDatabaseIfEmpty()`. Hàm này **return ngay nếu bảng exercises đã có dữ liệu**.
- Đã có sẵn: `exercise_library_screen.dart`, `create_exercise_screen.dart`, `widgets/exercise_picker_dialog.dart`, màn Active Workout, `RestTimerNotifier` (Timer.periodic).
- Thời lượng buổi tập đã tính từ `startedAt` (`Calculator.calculateDurationMinutes`), lưu theo **phút** (`durationMinutes`).
- Lịch sử có snapshot `exerciseName`, `planName`, `dayName` trong DB.

### Hệ quả quan trọng cho thiết kế

1. **Người dùng đã cài app sẽ không nhận thêm bài tập mới** nếu chỉ sửa `seed_data.dart`, vì seed bị bỏ qua khi bảng không rỗng. Cần cơ chế đồng bộ catalog (mục 3).
2. Bài tập seed cũ chỉ phân biệt bằng **tên**. Cần khoá ổn định (`catalogKey`) và backfill cho các dòng cũ.
3. Chuỗi `muscleGroup`/`equipment` đã nằm trong DB và trong file backup JSON. **Không đổi giá trị đã lưu** nếu chưa có migration cập nhật đúng và import backup cũ vẫn chạy.
4. Màn thêm bài, màn thư viện, màn tạo custom exercise **đã tồn tại**. Mở rộng chúng, không tạo bản trùng.

## 2. NGUYÊN TẮC CHUNG

1. Không rewrite project. Không đổi kiến trúc nếu không cần.
2. Không xoá hoặc reset database. Mọi thay đổi schema đi qua migration và có test nâng cấp từ dữ liệu thật.
3. Không seed trùng. Không ghi đè bài tập custom của người dùng.
4. Không hard-code chuỗi UI mới, không hard-code dữ liệu bài tập trong widget, không hard-code đường dẫn ảnh ở nhiều nơi.
5. Không đưa business logic hay SQL vào widget.
6. Không thêm dependency nếu SDK hoặc dependency hiện có đã đủ. (`flutter_localizations` thuộc SDK nên được phép.)
7. Làm tuần tự từng phase. Cuối mỗi phase: `dart format .`, `flutter analyze`, `flutter test` phải sạch rồi mới sang phase sau.
8. Không sửa tay `*.g.dart`, `.dart_tool/`, `build/`. Sau khi đổi bảng Drift chạy `dart run build_runner build --delete-conflicting-outputs`.
9. Nếu phát hiện vấn đề kiến trúc lớn, báo cáo trước khi sửa.
10. Không tuyên bố hoàn thành khi chưa kiểm tra thật. Nói rõ phần nào không kiểm tra được (ví dụ chưa chạy trên thiết bị).

## 3. THIẾT KẾ CHUNG: CATALOG BÀI TẬP

Dùng **một nguồn dữ liệu bài tập duy nhất** là file asset `assets/data/exercise_catalog.json` (thay cho danh sách hard-code trong `seed_data.dart`).

Mỗi mục trong catalog:

```text
key              (slug ổn định, ví dụ "bench_press", không bao giờ đổi)
muscleGroup      (khoá chuẩn)
secondaryMuscles (danh sách)
equipment        (khoá chuẩn)
exerciseType
names            { en, vi }
instructions     { en: [...], vi: [...] }
tips             { en: [...], vi: [...] }
images           [ đường dẫn asset ]  (có thể rỗng)
```

### Cột mới trong bảng Exercises (migration v2→v3, mọi cột nullable hoặc có default)

```text
catalogKey        text, nullable, unique   (null với custom exercise)
secondaryMuscles  text, nullable           (JSON/CSV)
instructions      text, nullable           (chỉ dùng cho custom exercise)
tips              text, nullable           (chỉ dùng cho custom exercise)
imageAsset        text, nullable           (đường dẫn tham chiếu, không lưu binary)
```

Giữ cột `name` là tên tiếng Anh (dùng cho tìm kiếm, snapshot, backup). Nội dung dịch (tên tiếng Việt, hướng dẫn, tips) của bài có sẵn **đọc từ catalog theo `catalogKey`**, không lưu vào DB. Bài custom lưu nội dung do người dùng nhập trong DB.

### Đồng bộ catalog (`ExerciseCatalogSync`)

- Chạy khi app khởi động, sau import backup, sau `clearAllData`.
- Chỉ chạy khi `catalogVersion` trong asset lớn hơn phiên bản đã lưu (lưu trong `shared_preferences`).
- **Upsert theo `catalogKey`** trong một transaction. Thêm bài mới, cập nhật metadata của bài có sẵn. **Không xoá** bài nào, **không đụng** bài `isCustom = true`.
- Backfill: trong migration hoặc lần sync đầu, gán `catalogKey` cho các dòng seed cũ (`isCustom = false`) bằng cách khớp tên với catalog. Dòng nào không khớp thì giữ nguyên.
- Nếu người dùng có custom exercise trùng tên với bài mới trong catalog: **giữ cả hai**, không gộp.
- Phải idempotent: chạy lại nhiều lần không sinh trùng.

### Giá trị chuẩn của nhóm cơ và thiết bị

Trước khi thêm bài, đọc `seed_data.dart` để biết chính xác các chuỗi hiện có (ví dụ `Shoulder` hay `Shoulders`). **Giữ nguyên các giá trị đã có trong DB.** Nhóm cơ mới thì dùng cùng quy ước. Việc dịch nhãn sang tiếng Việt làm ở tầng hiển thị bằng bảng ánh xạ, không đổi giá trị lưu.

### Backup JSON

Export/import phải tương thích ngược: file backup cũ (không có cột mới) vẫn import được; file mới có thêm các cột nullable. Import thất bại thì rollback, không làm hỏng DB hiện tại.

---

## PHASE 1 — MỞ RỘNG EXERCISE LIBRARY

### 1.1 Catalog

Tạo `exercise_catalog.json` với tối thiểu các bài sau (có thể thêm):

- **Chest:** Bench Press, Dumbbell Bench Press, Incline Bench Press, Incline Dumbbell Press, Decline Bench Press, Cable Fly, Pec Deck, Push Up
- **Back:** Pull Up, Chin Up, Lat Pulldown, Barbell Row, Dumbbell Row, Seated Cable Row, T-Bar Row, Chest Supported Row, Straight Arm Pulldown
- **Shoulders:** Overhead Press, Dumbbell Shoulder Press, Arnold Press, Lateral Raise, Cable Lateral Raise, Front Raise, Rear Delt Fly, Face Pull
- **Legs:** Back Squat, Front Squat, Leg Press, Romanian Deadlift, Deadlift, Bulgarian Split Squat, Leg Extension, Leg Curl, Calf Raise
- **Biceps:** Barbell Curl, Dumbbell Curl, Hammer Curl, Incline Dumbbell Curl, Preacher Curl, Cable Curl
- **Triceps:** Triceps Pushdown, Rope Pushdown, Skull Crusher, Overhead Triceps Extension, Close Grip Bench Press, Dumbbell Triceps Extension

Các bài đã có trong seed cũ (ví dụ "Squat", "Barbell Row", "One Arm Dumbbell Row") phải **khớp vào đúng mục catalog** qua backfill, không tạo bản trùng. Nếu tên cũ và tên mới khác nhau (ví dụ "Squat" và "Back Squat"), dùng `catalogKey` làm chuẩn và giữ lịch sử/plan đang trỏ đúng `exerciseId` cũ.

Nội dung `names.vi`, `instructions`, `tips` do agent viết: tiếng Việt tự nhiên, thuật ngữ gym người Việt quen dùng, không dịch máy móc. Giữ tên tiếng Anh trong ngoặc nếu thuật ngữ phổ biến hơn (ví dụ "Hít đất (Push Up)").

### 1.2 Chọn bài khi thêm vào Workout Day

Mở rộng `exercise_picker_dialog.dart` và `exercise_library_screen.dart` hiện có:

- Ô tìm kiếm (tìm theo tên en + vi + từ khoá, không phân biệt dấu/hoa thường).
- Chip lọc theo nhóm cơ; lọc thêm theo thiết bị và loại bài tập.
- Danh sách dạng card: ảnh thumbnail (hoặc placeholder), tên, nhóm cơ, thiết bị, nút ADD.
- Nhấn vào card mở **Exercise Detail**: ảnh, tên, nhóm cơ chính/phụ, thiết bị, mô tả, hướng dẫn từng bước, tips.
- Danh sách dài phải dùng `ListView.builder`/`SliverList` (lazy).
- Không hiện bài đã archive (xem plan_2 Task 1).

### 1.3 Custom exercise

Màn `create_exercise_screen.dart` **đã có**. Chỉ bổ sung các trường Instructions (và tuỳ chọn Tips, cơ phụ). Lưu SQLite, `isCustom = true`, `catalogKey = null`. Cho phép sửa custom exercise.

### 1.4 Tương thích Workout

Bài tập mới thêm vào Workout Day bằng đúng luồng hiện tại (`addExerciseToDay`). Không đổi hành vi plan/session/history cũ.

### Nghiệm thu Phase 1

- Catalog có đủ bài nêu trên, nạp từ asset, không hard-code trong UI.
- **Test nâng cấp:** tạo DB ở schema v1 (đã có seed cũ, plan, history, custom exercise), chạy migration + sync → còn nguyên mọi dữ liệu cũ, có thêm bài mới, không trùng, `catalogKey` được backfill đúng.
- Mở app lần 2 và lần 3 không sinh thêm bài.
- Search, filter, detail, thêm vào workout, tạo custom đều chạy và lưu qua restart.
- Plan, history, progress cũ không đổi.
- Import backup cũ vẫn thành công.

---

## PHASE 2 — LOCALIZATION: ENGLISH + TIẾNG VIỆT

### 2.1 Kiến trúc

- Dùng `flutter_localizations` (SDK) + `gen-l10n`: bật `generate: true` trong `pubspec.yaml`, thêm `l10n.yaml`, file `lib/l10n/app_en.arb` và `app_vi.arb`. Cấu hình `localizationsDelegates` và `supportedLocales` trong `MaterialApp.router`.
- Lưu lựa chọn ngôn ngữ qua `SettingsRepository` hiện có (`shared_preferences`), thêm `languageProvider` (Riverpod) giống cách `weightUnitProvider` đang làm. Mặc định: theo ngôn ngữ hệ thống nếu là vi/en, ngược lại English.
- Settings: mục **Language** với hai lựa chọn "English" và "Tiếng Việt" (mỗi tên hiển thị bằng chính ngôn ngữ của nó).
- Đổi ngôn ngữ phải cập nhật UI ngay, không cần khởi động lại.

### 2.2 Phạm vi chuỗi cần chuyển

Làm theo thứ tự: widget dùng chung và điều hướng → Home → Workout/Active Workout → History → Progress → Body → Exercises → Settings.

Dùng `grep` các literal như `Text('`, `title:`, `label:`, `hintText:`, `SnackBar` để không sót.

Các điểm **không có `context`** cần xử lý riêng:

- `Formatters.validateWeight/validateReps`: đổi để trả về mã lỗi hoặc nhận `AppLocalizations`.
- `NotificationService` (nội dung "Time to workout 💪", rest timer): truyền chuỗi đã dịch từ nơi gọi, hoặc đọc locale đã lưu.
- `Formatters` dùng `DateFormat`: truyền `locale` để ngày/tháng hiển thị đúng tiếng Việt.

### 2.3 Dữ liệu người dùng và dữ liệu seed

- Không dịch dữ liệu người dùng nhập (tên plan, tên ngày, ghi chú, custom exercise).
- Tên plan/ngày mà seed cũ đã ghi vào DB bằng tiếng Anh ("Push Pull Legs (PPL)"…) **giữ nguyên**, không migrate. Ghi vào báo cáo như hạn chế đã biết.
- Tên bài tập có sẵn: hiển thị theo ngôn ngữ hiện tại từ catalog (`names.vi`/`names.en`). Màn History hiển thị tên theo catalog khi bài còn tồn tại và có `catalogKey`; nếu không (bài custom đã xoá hoặc không có key) dùng snapshot `exerciseName`.
- Nhãn nhóm cơ/thiết bị dịch qua bảng ánh xạ ở tầng hiển thị, không đổi giá trị lưu.
- Nhãn đơn vị `kg`/`lb` giữ nguyên.

### 2.4 Bản dịch tiếng Việt (gợi ý)

Start Workout → Bắt đầu tập · Finish Workout → Kết thúc buổi tập · Add Exercise → Thêm bài tập · Workout History → Lịch sử tập luyện · Rest Timer → Đồng hồ nghỉ · Stopwatch → Đồng hồ bấm giờ · Progress → Tiến độ · Body Weight → Cân nặng. Các chuỗi còn lại dịch tự nhiên theo cùng phong cách.

### Nghiệm thu Phase 2

- Hai ngôn ngữ chạy đủ trên mọi màn hình chính, không còn chuỗi UI quan trọng hard-code.
- Ngôn ngữ được giữ sau restart app.
- Widget test với locale `vi` và `textScaler` lớn (1.3): không có `RenderFlex overflow` ở Home, Active Workout, Exercise library, Settings.
- Không ảnh hưởng database, workout, history.

---

## PHASE 3 — HÌNH MINH HỌA BÀI TẬP

### 3.1 Kiến trúc ảnh

```text
Exercise (catalogKey / imageAsset)
   → ExerciseImageSource (interface)
        → AssetExerciseImageSource  (hiện tại)
        → RemoteExerciseImageSource (tương lai, không làm bây giờ)
   → widget ExerciseImage
```

- Đường dẫn ảnh chỉ nằm trong `exercise_catalog.json` (hoặc `imageAsset` của custom), **không hard-code trong widget**.
- DB chỉ lưu tham chiếu, không lưu binary.
- Widget `ExerciseImage(exercise, size/fit, {thumbnail})`: có ảnh thì hiển thị; không có hoặc lỗi tải thì hiện **placeholder** (icon theo nhóm cơ). Dùng `errorBuilder`, không bao giờ crash.
- Thumbnail dùng `cacheWidth`/`cacheHeight` phù hợp kích thước hiển thị; danh sách dùng lazy loading.

### 3.2 Phase 3A — làm trước

Làm toàn bộ kiến trúc, `ExerciseImage` và placeholder, gắn vào card và Exercise Detail. App phải hoàn chỉnh và không crash ngay cả khi chưa có ảnh nào.

### 3.3 Phase 3B — nguồn ảnh

**Agent không được tự vẽ hay tự sinh ảnh minh họa.** Có hai lựa chọn, theo thứ tự ưu tiên:

1. **Người dùng tự cung cấp ảnh** đặt vào `assets/exercises/` theo quy ước tên `<catalogKey>_0.webp` (và `_1` cho vị trí kết thúc). Agent chỉ viết script/kiểm tra mapping và báo cáo bài nào còn thiếu ảnh.
2. **Dùng dataset mở `yuhonas/free-exercise-db`** (800+ bài, mỗi bài có ảnh, phát hành theo giấy phép Unlicense / public domain). Điều kiện:
   - Đọc `LICENSE.md` trong repo ngay trước khi dùng để xác nhận lại giấy phép.
   - Chỉ lấy ảnh của các bài có trong catalog của mình (khớp theo tên), không nhúng cả bộ.
   - **Bundle vào `assets/`** để chạy offline. Không tải từ internet khi app chạy.
   - Đây là **ảnh chụp thật**, không phải minh họa vẽ; bộ ảnh đồng nhất phong cách nhưng khác với "illustration" nêu trong roadmap cũ. Hướng dẫn trong dataset chỉ có tiếng Anh, vẫn viết bản tiếng Việt riêng ở catalog.
   - Thêm ghi công nguồn vào mục About trong Settings.
   - Nếu agent không có truy cập mạng để lấy ảnh, dừng ở 3A và báo người dùng tải thủ công.

### 3.4 Hiệu năng và dung lượng

- Giới hạn khoảng 600 px cạnh dài, định dạng WebP hoặc JPEG nén, mục tiêu dưới ~100 KB mỗi ảnh.
- Báo cáo kích thước APK trước và sau khi thêm ảnh. Nếu tăng đáng kể, đề xuất `--split-per-abi`.
- Mở thư viện ~60 bài phải cuộn mượt.

### Nghiệm thu Phase 3

- Có `ExerciseImageSource`, `ExerciseImage`, placeholder.
- Card hiển thị thumbnail, Detail hiển thị ảnh lớn.
- Xoá thử một file ảnh khỏi assets → app vẫn chạy, hiện placeholder.
- Không còn đường dẫn ảnh nằm trong widget.
- Báo cáo bài nào đã có ảnh, bài nào còn thiếu, và nguồn/giấy phép ảnh.

---

## PHASE 4 — STOPWATCH

Stopwatch (đếm lên) **khác** Rest Timer (đếm ngược), hai thứ độc lập và có thể chạy cùng lúc.

### 4.1 Hành vi

- Trạng thái: `Idle`, `Running`, `Paused`. (Bỏ trạng thái "Finished" của roadmap cũ vì stopwatch không tự kết thúc.)
- Nút: Start, Pause, Resume, Reset. **Lap**: làm luôn bản đơn giản (danh sách lap kèm thời gian từng vòng) nếu không tốn nhiều công; nếu tốn thì để sau và ghi vào báo cáo.
- Hiển thị `HH:MM:SS` (thêm phần mười giây nếu muốn).

### 4.2 Cách tính giờ (bắt buộc)

Không dùng biến đếm tăng mỗi giây. Lưu:

```text
status
startedAt        (thời điểm bắt đầu/tiếp tục chạy gần nhất)
accumulated      (tổng thời gian đã chạy trước các lần pause)
laps
```

`elapsed = accumulated + (now - startedAt)` khi đang chạy, `accumulated` khi đang pause. Timer/ticker của UI chỉ để vẽ lại, giá trị luôn tính từ timestamp.

- Lưu trạng thái vào `shared_preferences` để không mất khi app bị hệ thống kill hoặc rebuild widget.
- Tiêm hàm lấy thời gian (`DateTime Function() now`) để test được bằng đồng hồ giả.
- Đặt logic trong provider/notifier riêng (`StopwatchNotifier`), không để trong widget.

### 4.3 Vị trí trong app

Không thêm tab thứ 6. Thêm route `/stopwatch` nằm ngoài shell, mở từ nút nhanh ở Home và từ app bar của màn Active Workout.

### 4.4 Workout duration

Thời lượng buổi tập **đã** tính theo `startedAt`. Việc cần làm: kiểm tra màn Active Workout hiển thị thời gian đang chạy tính từ `startedAt` (không phải counter), và duration lưu khi Finish đúng. Không cần đổi sang giây trừ khi có lý do rõ ràng (nếu đổi thì phải qua migration và cập nhật backup).

### Nghiệm thu Phase 4

- Start/Pause/Resume/Reset chạy đúng, không reset khi rebuild widget.
- Khoá màn hình hoặc chuyển app rồi quay lại: thời gian đúng. Giả lập bằng đồng hồ giả trong unit test.
- Kill app khi đang chạy rồi mở lại: trạng thái được khôi phục.
- Rest Timer hiện có không bị ảnh hưởng.

---

## PHASE 5 — TÍCH HỢP UX

Rà một vòng luồng chính sau khi bốn tính năng xong:

- Exercises → Search → Filter → Card → Detail → Add to Workout
- Start Workout → Duration → Exercise → Sets → Rest Timer → Next → Finish
- Settings: Language, Theme, Notifications, Default Rest Time, About (ghi công nguồn ảnh)

Sửa các chỗ thiếu nhất quán (chuỗi chưa dịch, thiếu placeholder, điều hướng).

---

## PHASE 6 — TEST & REGRESSION

Test cả chức năng mới lẫn cũ.

- **Migration:** DB v1 có dữ liệu thật → nâng cấp → nguyên vẹn (plan, session, set, body, progress, custom exercise).
- **Catalog sync:** idempotent, không trùng, không đụng custom, backfill đúng.
- **Exercise:** search (có dấu/không dấu), filter, thêm/bớt bài, detail, custom, ảnh thiếu.
- **Localization:** chọn Vietnamese → restart → vẫn Vietnamese; ngược lại với English; không overflow với `vi` và text scale lớn.
- **Stopwatch:** Start/Pause/Resume/Reset, background (đồng hồ giả), khôi phục sau kill.
- **Backup:** import file backup cũ thành công; file hỏng báo lỗi và không phá DB.
- **Flow đầy đủ** (integration test nếu đã có `integration_test/` từ plan_2 Task 7): Tạo plan → Thêm bài → Start → Stopwatch → Thêm set → Hoàn thành set → Rest timer → Finish → History → Progress.

## PHASE 7 — HIỆU NĂNG & RELEASE

Chạy `flutter analyze`, `flutter test` (và `flutter test integration_test` nếu có). Kiểm tra: thời gian khởi động, cuộn thư viện bài tập, tải ảnh, dark mode, giao diện tiếng Việt và tiếng Anh, chế độ offline (tắt mạng), notification. Build release APK, báo cáo kích thước. Phần nào cần thiết bị thật mà không chạy được thì ghi rõ là chưa kiểm tra.

---

## ĐỊNH NGHĨA HOÀN THÀNH

**Exercise:** nhiều bài tập từ catalog · search · filter · detail · custom · thêm vào workout · người dùng cũ nhận bài mới mà không mất dữ liệu.
**Language:** English · Tiếng Việt · giữ sau restart · cập nhật ngay.
**Images:** kiến trúc ảnh · placeholder · fallback · không crash khi thiếu · hiệu năng tốt · ghi nguồn và giấy phép.
**Stopwatch:** Start/Pause/Resume/Reset · tính theo timestamp · khôi phục sau kill · Rest Timer không ảnh hưởng.
**Data:** không mất dữ liệu cũ · migration an toàn có test · offline · backup cũ vẫn import được.
**Quality:** analyze sạch · test pass · không hồi quy nghiêm trọng · release APK build được.

## BÁO CÁO SAU MỖI PHASE

1. Các file đã thay đổi.
2. Thay đổi database và migration (version nào).
3. Dependency mới (nếu có).
4. Tính năng đã làm.
5. Kết quả thật của `flutter analyze` và `flutter test`.
6. Phần chưa kiểm tra được và lý do.
7. Vấn đề đã biết.
8. Phase tiếp theo.
