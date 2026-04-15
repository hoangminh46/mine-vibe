# 🚀 Hướng Dẫn Sử Dụng Skill Cùng Google NotebookLM

Tài liệu này hướng dẫn bạn (người dùng) cách tận dụng tối đa sức mạnh phân tích tài liệu của **Google NotebookLM** kết hợp với năng lực sinh văn bản và dàn trang tự động của skill **`essay-writer`**. 

Quy trình này đảm bảo bài tiểu luận CỰC KỲ SÂU SẮC, bám sát sách giáo trình của giảng viên mà KHÔNG BỊ TRÙNG LẶP hay lan man.

---

## 📍 BƯỚC 1: VẮT KIỆT TÀI LIỆU VỚI NOTEBOOKLM

1. Truy cập **[Google NotebookLM](https://notebooklm.google.com/)** và tạo một Notebook mới cho môn học.
2. Tải toàn bộ tài liệu hệ trọng lên (File PDF luận văn, Slide giảng viên cung cấp, sách tham khảo...). Bạn có thể tải lên tới 50 nguồn.
3. Trong khung chat của NotebookLM, gửi câu lệnh (Prompt) "thần thánh" sau:

   > _"Anh đang cần viết một bài tiểu luận cuối kì cực kỳ chuyên sâu về chủ đề **[Điền tên chủ đề]**. Dựa vào toàn bộ dữ liệu trong các nguồn đã tải lên, em hãy trích xuất toàn bộ kiến thức và tạo cho anh nguyên một BỘ CƠ SỞ DỮ LIỆU chi tiết. 
   > **YÊU CẦU QUAN TRỌNG:** 
   > - Trình bày dài nhất và chi tiết nhất có thể, đi sâu vào tận cùng các khái niệm. TUYỆT ĐỐI KHÔNG tóm tắt hay lược bỏ ý.
   > - SỬ DỤNG 100% TIẾNG VIỆT THUẦN TÚY. Tuyệt đối KHÔNG giữ lại các từ tiếng Anh (ví dụ: cấm dùng kiểu 'Siêu nhận thức (metacognition)'). Nếu tài liệu gốc có tiếng Anh, phải dịch hẳn sang tiếng Việt.
   > - Với mỗi mục nhỏ (1.1, 1.1.1), trích dẫn nguyên văn lý thuyết, số liệu, định nghĩa và bắt buộc ghi rõ nguồn tên tài liệu/tác giả.
   > - Liệt kê mọi luận điểm gốc để làm 'nguyên liệu thô' cho một bài dài 20+ trang."_

4. Đợi AI của Google xử lý. Sau khi nó trả ra toàn bộ khối kiến thức khổng lồ đó, **bạn hãy Copy toàn bộ câu trả lời**.

---

## 📍 BƯỚC 2: TẠO FILE TÀI LIỆU ".TXT" HOẶC ".MD"

Vì khối lượng kiến thức đổ ra từ NotebookLM có thể rất dài, bạn nên lưu nó vào một file thay vì dán trực tiếp vào khung chat để Mine dễ đọc nhất:
1. Trong VS Code (thư mục dự án), tạo một file mới có đuôi là `.txt` hoặc `.md` (VD: `data-tieuluan.txt`).
2. Dán toàn bộ nội dung bạn vừa copy từ NotebookLM vào file này và lưu lại.

---

## 📍 BƯỚC 3: KÍCH HOẠT TRỢ LÝ MINE TRONG VS CODE

Bạn mở khung chat với Mine (hoặc tạo conversation mới), gọi đúng tên kỹ năng và chỉ định đường dẫn file vừa tạo:

> _"Mine ơi, kích hoạt skill **essay-writer** để làm bài tiểu luận môn **[Tên môn]**. 
> Công việc của em là diễn giải, viết bóng bẩy và phát triển dài ra dựa trên 100% lượng kiến thức thô anh đã thu thập trong file **`data-tieuluan.txt`**.
> Yêu cầu: 
> - Đào sâu phân tích theo cấu trúc và chia nhỏ các ý để đảm bảo nội dung cực kỳ đầy đủ, tối thiểu **20+ trang**. Dẫn nguồn đầy đủ.
> - SỬ DỤNG 100% TIẾNG VIỆT THUẦN TÚY. Cấm tuyệt đối việc chèn từ vựng tiếng Anh hay giải nghĩa bằng từ tiếng Anh trong ngoặc (Ví dụ cấm viết: Mô hình 5E (Engage - Khám phá)). Dịch toàn bộ ra tiếng Việt."_

---

## 📍 BƯỚC 4: ĐIỀN THÔNG TIN BÌA & CHỐT FILE

1. Ngay khi nhận lệnh, Mine sẽ lập tức "ăn" file text đó, chuyển hóa các kiến thức từ NotebookLM thành các đoạn văn mạch lạc dài hàng nghìn chữ. 
2. Mine sẽ chạy script để đổ text vào file `.docx` định dạng chuẩn của ĐH Giáo Dục.
3. Mine có thể sẽ hỏi bạn các thông tin cá nhân:
   - _Họ tên, Mã học viên, Ngày sinh, Lớp/Khóa, Tên giảng viên chuyên ngành._
   *(Bạn có thể cung cấp luôn để Mine ghi vào trang bìa, hoặc tự điền sau).*
4. Sau 1-2 phút, file tiểu luận `.docx` hoàn chỉnh sẽ ra lò ở khu vực dự án.

---

## 💡 MẸO NHỎ KHI MỞ FILE TRONG MICROSOFT WORD

Do Mine khởi tạo Mục Lục tự động (Automatic Table of Contents) bằng máy nên khi mới tải file về, có thể số trang của Mục Lục chưa hiển thị ngay. Đừng lo lắng!

- **Thao tác:** Bấm mở file lên $\to$ Click chuột phải vào khu vực MỤC LỤC $\to$ Chọn **`Update Field`** (Cập nhật Trường) $\to$ Chọn **`Update entire table`** (Cập nhật toàn bộ bảng).
- Ngay lập tức mục lục sẽ trải ra cực kỳ đẹp và chính xác, tự động nối đúng trang.
- Nhớ lướt xuống trang thứ 2 kiểm tra số Footer (số "2") đã được đánh ở giữa trang chưa nhé!
