--Ràng buộc khi thêm mới nhân viên thì mức lương phải lớn hơn 15000, nếu vi phạm thì xuất thông báo “luong phải >15000’
create trigger trg_insert_NhanVien on NhanVien
   FOR INSERT
AS
   IF (SELECT LUONG FROM inserted)<15000
   BEGIN
      PRINT 'Lương phải lớn hơn 15000'
	  rollback transaction
   END

INSERT INTO NHANVIEN(HONV, TENLOT, TENNV, MANV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
			VALUES('Cao', N'Nhật', N'Hào', '0080099', '19/02/2002', '70A Trương phước phan', 'Nam', '100000000', '0950099', '12')
GO

--Ràng buộc khi thêm mới nhân viên thì độ tuổi phải nằm trong khoảng 18 <= tuổi <=65.
create trigger trg_insert_NhanVien2 on NhanVien
   FOR INSERT
AS
   Declare @age int
   Set @age = YEAR(GETDATE())-(select year NGSINH FROM inserted)
   if @age <18 or @age >65
   begin
      print N'Tuổi của nhân viên không hợp lệ'
	  rollback transaction;
   end
   go

INSERT INTO [dbo].[NHANVIEN] ([HONV],[TENLOT],[TENNV] ,[MANV] ,[NGSINH],[DCHI],[PHAI],[LUONG],[MA_NQL],[PHG])
     VALUES('Cao',N'Nhật',N'Hào','0080099','19/02/2002', '70A Trương phước phan', 'Nam', '100000000', '0950099', '12')
---Ràng buộc khi cập nhật nhân viên thì không được cập nhật những nhân viên ở TP HCM
create trigger trg_Kiemtraupdate_NV on NHANVIEN
   FOR UPDATE
AS
   IF EXISTS (SELECT DCHI FROM inserted where DCHI LIKE '%TP.HCM%')
   BEGIN
      PRINT N'Không thể cập nhật nhân viên ở TP.HCM';
	  rollback tran;
   END;
---câu lệnh kiểm tra
UPDATE [dbo].[NHANVIEN]
   SET [PHAI] = 'Nam'
 WHERE MaNV = '001';
GO

----bài 2a Hiển thị tổng số lượng nhân viên nữ, tổng số lượng nhân viên nam mỗi khi có hành động thêm mới nhân viên.
create trigger trg_TongNhanVien on NHANVIEN
   AFTER INSERT
AS
   Declare @male int, @female int;
   select @female = count(Manv) from NHANVIEN where PHAI = N'Nữ';
   select @male = count(Manv) from NHANVIEN where PHAI = N'Nam';
   print N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
   print N'Tổng số nhân viên là nam: ' + cast(@male as varchar);

---CÂU LỆNH KIỂM TRA
INSERT INTO [dbo].[NHANVIEN] ([HONV],[TENLOT],[TENNV] ,[MANV] ,[NGSINH],[DCHI],[PHAI],[LUONG],[MA_NQL],[PHG])
     VALUES('Cao',N'Nhật',N'Hào','0080099','19/02/2002', '70A Trương phước phan', 'Nam', '100000000', '0950099', '12')
GO
 --BÀI 2b Hiển thị tổng số lượng nhân viên nữ, tổng số lượng nhân viên nam mỗi khi có hành động cập nhật phần giới tính nhân viên
 create trigger trg_TongNhanVienUpdate on NHANVIEN
   AFTER update
AS
   if (select top 1 PHAI FROM deleted) != (select top 1 PHAI FROM inserted)
   begin
      Declare @male int, @female int;
      select @female = count(Manv) from NHANVIEN where PHAI = N'Nữ';
      select @male = count(Manv) from NHANVIEN where PHAI = N'Nam';
      print N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
      print N'Tổng số nhân viên là nam: ' + cast(@male as varchar);
   end;
--câu lệnh kiểm tra
UPDATE [dbo].[NHANVIEN]
   SET [HONV] = 'Hà'
      ,[PHAI] = N'Nữ'
 WHERE  MaNV = '84021'
GO
---BÀI 2C Hiển thị tổng số lượng đề án mà mỗi nhân viên đã làm khi có hành động xóa trên bảng DEAN
CREATE TRIGGER trg_TongNhanVienDelete on DEAN
   AFTER DELETE
AS
   SELECT MA_NVIEN, COUNT(MaDA) as 'Tổng sô đề án đã tham gia' from PHANCONG
      GROUP BY MA_NVIEN
	end;
	SELECT * FROM DEAN
insert into dean values ('Big data', 43, 'CNH', 22)
delete from dean where MADA=43
---Câu 3a)Xóa các thân nhân trong bảng thân nhân có liên quan khi thực hiện hành động xóa nhân viên trong bảng nhân viên.
create trigger delete_thannhan on NHANVIEN
instead of delete
as
begin
delete from THANNHAN where MA_NVIEN in(select manv from deleted)
delete from NHANVIEN where manv in(select manv from deleted)
end
insert into THANNHAN values ('VQ2002', 'Quyền', 'Nam', '04/08/1996', 'Vợ')
delete NHANVIEN where manv='VQ2002'

----Câu 3b Khi thêm một nhân viên mới thì tự động phân công cho nhân viên làm đề án có MADA là 1.
create trigger trg_insert_NhanVien3 on NHANVIEN
after insert 
as
begin
insert into PHANCONG values ((select manv from inserted), NH2002,43,15)
end
INSERT INTO NHANVIEN VALUES ('Cao',N'Nhật',N'Hào','0080099','19/02/2002','Quảng Bình','Nam',100000000,'0950099',1)