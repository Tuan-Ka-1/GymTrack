\# ROLE



Bạn là một Senior Flutter Developer + Software Architect + UI/UX Designer.



Hãy xây dựng hoàn chỉnh một ứng dụng Android có tên \*\*GymTrack\*\* — ứng dụng quản lý lịch tập gym và theo dõi tiến bộ cá nhân.



Tôi muốn ứng dụng chạy \*\*hoàn toàn local/offline trên điện thoại\*\*, không phụ thuộc server hoặc máy tính sau khi cài APK.



\---



\# 1. MỤC TIÊU



Ứng dụng phải cho phép người dùng:



1\. Tạo và quản lý lịch tập gym.

2\. Tạo các buổi tập.

3\. Quản lý danh sách bài tập.

4\. Trong mỗi bài tập có nhiều set.

5\. Ghi:



&#x20;  \* Weight

&#x20;  \* Reps

&#x20;  \* RPE/RIR tùy thiết kế

&#x20;  \* Rest time

6\. Xem thành tích của các buổi tập trước.

7\. Theo dõi tiến bộ theo thời gian.

8\. Theo dõi cân nặng và một số chỉ số cơ thể.

9\. Có rest timer.

10\. Có thống kê và biểu đồ.

11\. Có notification nhắc lịch tập.

12\. Tất cả dữ liệu chính phải được lưu local trên điện thoại.



Không yêu cầu đăng nhập ở phiên bản đầu tiên.



Không cần backend.



Không cần Internet để sử dụng các chức năng chính.



\---



\# 2. TECH STACK



Sử dụng:



\* Flutter

\* Dart

\* Material 3

\* Riverpod để quản lý state

\* Drift + SQLite để lưu dữ liệu local

\* fl\_chart cho biểu đồ

\* flutter\_local\_notifications cho notification

\* go\_router cho navigation



Không sử dụng Firebase trong phiên bản đầu tiên.



Không sử dụng backend.



Không sử dụng API bên ngoài nếu không cần thiết.



Thiết kế kiến trúc sao cho sau này có thể bổ sung cloud sync nhưng hiện tại app phải hoạt động 100% offline.



\---



\# 3. KIẾN TRÚC



Sử dụng kiến trúc rõ ràng, dễ mở rộng.



Đề xuất:



lib/



core/

constants/

theme/

utils/

widgets/



data/

database/

app\_database.dart

tables/

daos/



```

repositories/

```



domain/

models/

repositories/



features/



```

home/



workout/



exercises/



history/



progress/



body/



settings/

```



routing/



main.dart



Có thể điều chỉnh cấu trúc nếu có lý do kỹ thuật rõ ràng.



Không viết toàn bộ ứng dụng vào một file.



Không để business logic trực tiếp trong UI.



\---



\# 4. DATABASE



Sử dụng Drift + SQLite.



Thiết kế database có ít nhất các entity:



\## Exercise



\* id

\* name

\* muscleGroup

\* equipment

\* exerciseType

\* description

\* createdAt

\* updatedAt



\## WorkoutPlan



\* id

\* name

\* description

\* createdAt

\* updatedAt



\## WorkoutDay



\* id

\* workoutPlanId

\* name

\* dayOfWeek

\* orderIndex



\## WorkoutExercise



\* id

\* workoutDayId

\* exerciseId

\* orderIndex

\* targetSets

\* targetMinReps

\* targetMaxReps

\* restSeconds



\## WorkoutSession



\* id

\* workoutDayId

\* startedAt

\* finishedAt

\* notes



\## ExerciseSession



\* id

\* workoutSessionId

\* exerciseId

\* orderIndex

\* notes



\## WorkoutSet



\* id

\* exerciseSessionId

\* setNumber

\* weight

\* reps

\* rpe

\* rir

\* restSeconds

\* completed

\* createdAt



\## BodyMeasurement



\* id

\* date

\* bodyWeight

\* bodyFat

\* chest

\* waist

\* arm

\* thigh

\* notes



\## PersonalRecord



Có thể tính động từ WorkoutSet thay vì lưu riêng nếu hợp lý.



\---



\# 5. DATABASE RULES



Thiết lập foreign key rõ ràng.



Xử lý cascade delete hợp lý.



Không để orphan records.



Tất cả timestamp lưu theo cách nhất quán.



Database phải hỗ trợ migration.



Không xóa dữ liệu lịch sử chỉ vì workout plan hiện tại bị thay đổi.



Ví dụ:



Nếu người dùng sửa workout plan:



Bench Press từ 60kg thành 70kg,



thì lịch sử các buổi tập cũ vẫn phải giữ nguyên.



\---



\# 6. MAIN UI



Tạo Bottom Navigation:



1\. Home

2\. Workout

3\. History

4\. Progress

5\. Settings



Material 3.



UI hiện đại, tối giản, phù hợp ứng dụng fitness.



Hỗ trợ Dark Mode.



Thiết kế responsive cho điện thoại Android.



\---



\# 7. HOME



Home hiển thị:



\* Greeting

\* Today's workout

\* Workout duration

\* Last workout

\* Current body weight

\* Recent PR

\* Quick Start Workout button



Ví dụ:



TODAY



Push



Bench Press

Incline Dumbbell Press

Shoulder Press

Lateral Raise

Triceps Pushdown



\[START WORKOUT]



\---



\# 8. WORKOUT PLAN



Cho phép:



\* Create workout plan

\* Rename workout plan

\* Delete workout plan

\* Add workout days

\* Rename workout days

\* Add exercise

\* Remove exercise

\* Reorder exercise



Ví dụ:



PPL



Monday

Push



Tuesday

Pull



Wednesday

Rest



Thursday

Legs



\---



\# 9. EXERCISE LIBRARY



Tạo một danh sách exercise mặc định.



Ít nhất:



CHEST:



\* Bench Press

\* Incline Bench Press

\* Dumbbell Bench Press

\* Incline Dumbbell Press

\* Cable Fly



BACK:



\* Pull Up

\* Lat Pulldown

\* Barbell Row

\* Seated Cable Row

\* One Arm Dumbbell Row



SHOULDER:



\* Overhead Press

\* Dumbbell Shoulder Press

\* Lateral Raise

\* Rear Delt Fly

\* Face Pull



LEGS:



\* Squat

\* Leg Press

\* Romanian Deadlift

\* Leg Curl

\* Leg Extension

\* Calf Raise



BICEPS:



\* Barbell Curl

\* Dumbbell Curl

\* Hammer Curl



TRICEPS:



\* Triceps Pushdown

\* Skull Crusher

\* Overhead Triceps Extension



Cho phép người dùng tạo custom exercise.



\---



\# 10. WORKOUT SESSION



Khi người dùng bấm:



START WORKOUT



tạo một WorkoutSession.



Hiển thị:



Exercise:



Bench Press



Previous:



60kg × 10

60kg × 10

65kg × 8



Current:



Set 1

Weight \[60] kg

Reps \[10]



Set 2

Weight \[60] kg

Reps \[10]



Set 3

Weight \[ ] kg

Reps \[ ]



\[+ ADD SET]



Có checkbox để đánh dấu set completed.



\---



\# 11. AUTO-FILL PREVIOUS PERFORMANCE



Đây là chức năng quan trọng.



Khi bắt đầu bài tập:



App phải lấy workout gần nhất của exercise đó.



Ví dụ:



Previous workout:



60 × 10

60 × 9

60 × 8



Hiển thị để người dùng tham khảo.



Không tự động ghi đè dữ liệu mới.



\---



\# 12. REST TIMER



Sau khi hoàn thành set:



Hiển thị rest timer.



Ví dụ:



REST



01:30



\[+30 sec]



\[SKIP]



Cho phép cấu hình thời gian nghỉ mặc định theo exercise.



Timer phải hoạt động khi app ở trạng thái phù hợp trong background nếu Android cho phép.



\---



\# 13. WORKOUT FINISH



Khi bấm:



FINISH WORKOUT



Hiển thị summary:



Workout completed



Duration:

58 min



Exercises:

5



Sets:

18



Total Volume:

7,420 kg



PR:

Bench Press +5kg



Cho phép thêm notes.



\---



\# 14. HISTORY



History hiển thị:



\* ngày tập

\* workout plan

\* duration

\* total volume

\* số bài tập

\* số set



Cho phép mở một workout để xem toàn bộ chi tiết.



Không cho phép lịch sử bị mất khi workout plan thay đổi.



\---



\# 15. PROGRESS



Tạo dashboard.



Theo dõi:



\* Body weight

\* Total workout

\* Total volume

\* Personal records

\* Exercise progress



Cho phép chọn exercise:



Bench Press



Hiển thị chart:



\* Weight over time

\* Volume over time

\* Estimated 1RM over time



Dùng fl\_chart.



Không hard-code dữ liệu chart.



Chart phải lấy dữ liệu từ SQLite.



\---



\# 16. ESTIMATED 1RM



Có thể sử dụng Epley:



1RM = weight × (1 + reps / 30)



Chỉ sử dụng cho mục đích thống kê.



Hiển thị rõ đây là estimated value.



\---



\# 17. BODY TRACKING



Cho phép nhập:



\* Weight

\* Body fat

\* Chest

\* Waist

\* Arm

\* Thigh



Hiển thị chart body weight.



\---



\# 18. NOTIFICATION



Cho phép người dùng:



\* bật/tắt workout reminder

\* chọn ngày

\* chọn giờ



Notification:



"Time to workout 💪"



Tất cả notification phải là local notification.



Không cần server.



\---



\# 19. SETTINGS



Settings gồm:



\* Dark mode

\* Workout reminder

\* Default rest timer

\* Weight unit: kg/lb

\* Export data

\* Import data

\* Delete all data

\* About



Trước khi Delete All Data phải có confirmation dialog.



\---



\# 20. BACKUP



Phiên bản đầu tiên không cần cloud.



Nhưng hãy thiết kế:



Export database/data thành JSON hoặc SQLite backup.



Cho phép người dùng lưu file backup.



Có chức năng Import backup.



Mục tiêu là nếu đổi điện thoại người dùng có thể khôi phục dữ liệu.



\---



\# 21. OFFLINE REQUIREMENT



Đây là yêu cầu bắt buộc:



Sau khi APK được cài:



Tắt Wi-Fi.



Tắt mobile data.



App vẫn phải:



\* mở được

\* xem workout

\* tạo workout

\* ghi set

\* xem history

\* xem progress

\* sử dụng timer

\* lưu database

\* sử dụng notification



Không gọi API bên ngoài cho các chức năng trên.



\---



\# 22. DATA SAFETY



Không được:



\* hard-code dữ liệu người dùng

\* lưu dữ liệu workout chỉ trong memory

\* mất dữ liệu khi restart app

\* reset database mỗi lần chạy app



Database phải persistent.



\---



\# 23. SEED DATA



Khi cài lần đầu:



Tự động seed exercise library.



Không seed lại mỗi lần app khởi động.



Nếu database đã có dữ liệu thì không được duplicate exercises.



\---



\# 24. ERROR HANDLING



Xử lý:



\* database error

\* invalid input

\* empty workout

\* invalid weight

\* invalid reps

\* failed import

\* corrupted backup



Không để app crash vì input thông thường.



Hiển thị error message dễ hiểu.



\---



\# 25. VALIDATION



Weight:



> = 0



Reps:



> = 0



Sets:



> = 1



Không cho phép nhập NaN hoặc giá trị không hợp lệ.



\---



\# 26. TESTING



Viết ít nhất:



Unit tests:



\* 1RM calculation

\* volume calculation

\* workout duration

\* repository/database operations



Widget tests:



\* Home

\* Workout

\* Add Set

\* History



Integration test cho flow:



Create plan

→ Start workout

→ Add exercise

→ Add sets

→ Finish workout

→ Open history

→ Verify data



\---



\# 27. CODE QUALITY



Yêu cầu:



\* Null safety

\* Clean code

\* Meaningful names

\* Không duplicate code

\* Không giant widgets

\* Tách reusable widgets

\* Repository pattern

\* Không để SQL trực tiếp trong UI

\* Không để business logic trong widget

\* Comment chỉ khi thực sự cần thiết



\---



\# 28. UI/UX



Thiết kế ưu tiên:



\* dễ bấm khi đang tập

\* button đủ lớn

\* text dễ đọc

\* số kg/reps dễ nhập

\* ít thao tác

\* không cần mở nhiều màn hình để ghi một set



Khi đang workout:



Ưu tiên tốc độ thao tác hơn trang trí.



\---



\# 29. DEVELOPMENT PROCESS



Không chỉ tạo skeleton rồi dừng.



Hãy thực hiện tuần tự:



STEP 1

Phân tích requirements.



STEP 2

Thiết kế architecture.



STEP 3

Thiết kế database.



STEP 4

Tạo Flutter project.



STEP 5

Cấu hình dependencies.



STEP 6

Implement database.



STEP 7

Implement repositories.



STEP 8

Implement state management.



STEP 9

Implement UI.



STEP 10

Implement workout flow.



STEP 11

Implement history.



STEP 12

Implement progress.



STEP 13

Implement notification.



STEP 14

Implement backup/restore.



STEP 15

Write tests.



STEP 16

Run analyzer.



STEP 17

Run tests.



STEP 18

Fix all errors.



STEP 19

Build release APK.



\---



\# 30. IMPORTANT AI AGENT RULE



Bạn là coding agent, vì vậy hãy chủ động thực hiện công việc.



Không chỉ đưa cho tôi code mẫu.



Hãy:



1\. Kiểm tra môi trường hiện tại.

2\. Kiểm tra Flutter/Dart version.

3\. Kiểm tra project hiện tại.

4\. Nếu project chưa tồn tại, tạo project.

5\. Nếu project đã tồn tại, phân tích trước khi sửa.

6\. Tạo từng file cần thiết.

7\. Chạy formatter.

8\. Chạy flutter analyze.

9\. Chạy test.

10\. Sửa lỗi.

11\. Build APK nếu môi trường hỗ trợ.



Không phá hủy code hiện tại nếu không cần thiết.



Trước khi thay đổi một phần lớn architecture, hãy kiểm tra code hiện tại.



\---



\# 31. DEVELOPMENT PRIORITY



Nếu không thể hoàn thành tất cả trong một lần, ưu tiên theo thứ tự:



P0:



\* Flutter project

\* SQLite

\* Exercise

\* Workout Plan

\* Workout Session

\* Workout Set

\* Home

\* Start Workout

\* Save workout

\* History



P1:



\* Previous performance

\* Rest timer

\* Progress

\* Charts

\* Body tracking



P2:



\* Notification

\* Backup/restore

\* Advanced statistics

\* RPE/RIR

\* Dark mode improvements



\---



\# 32. DEFINITION OF DONE



Không coi task hoàn thành chỉ vì code đã được viết.



Task chỉ được coi là hoàn thành khi:



\* flutter analyze không còn lỗi nghiêm trọng

\* tests pass

\* app chạy được

\* database persistent

\* tạo workout được

\* thêm exercise được

\* thêm set được

\* lưu weight/reps được

\* đóng app mở lại dữ liệu vẫn còn

\* history hiển thị dữ liệu

\* progress lấy dữ liệu thực từ database

\* app hoạt động offline



Cuối cùng hãy báo cáo:



1\. Các file đã tạo/thay đổi.

2\. Architecture.

3\. Database schema.

4\. Dependencies.

5\. Các chức năng đã hoàn thành.

6\. Tests đã chạy.

7\. Kết quả flutter analyze.

8\. APK nằm ở đâu.

9\. Những chức năng chưa hoàn thành.

10\. Các bước tiếp theo.



Không tuyên bố "hoàn thành" nếu chưa kiểm tra thực tế.



