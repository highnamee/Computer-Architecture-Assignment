##################################################################
####----------------------------------------------------------####
####         CODE CONG VA TRU 2 SO THUC CHINH XAC DON         ####
####                    Nhom L07_12                           ####
####----------------------------------------------------------####
##################################################################

# Luu 2 so thuc chinh xac don vao vung .data
.data
		# Cac chuoi xuat ra console
		str1: 	.asciiz	"Moi nhap vao a: "
		str2: 	.asciiz	"Moi nhap vao b: "
		str3: 	.asciiz	"Ket qua a + b: "
		str4: 	.asciiz	"\nKet qua a - b: "
	
# Bat dau vung .text
.text
# Bat dau chay o ham main
		j	main
		

#----------------------------------------------------------------#
#           B1: TACH SO THUC THANH CAC THANH PHAN                #
#----------------------------------------------------------------#
# So thuc chinh xac don: |1 bit dau|8 bit so mu|23 bit phan so|  #
# Ta se lay cac bit nay ra bang cach andi hoac ori Num1/Num2 roi # 
# sao chep gia tri trong do                       		#
# De de dang tinh toan ta se luu Num1/Num2 vao cac thanh ghi     #
# binh thuong ma khong su dung thanh ghi so thuc                 #
#----------------------------------------------------------------#

# -----------------$t0 = a;  $t1 = b ----------------------------#
# $s0 = t0[31] ; $s1 = t0[30:23]; $s2 = [1:t0[22:0]] ------------#
# $s3 = t1[31] ; $s4 = t1[30:23]; $s5 = [1:t0[22:0]] ------------#

		
#------------------Load cac gia tri cua Num1---------------------# 
#----(bit dau vao $s0, phan mu vao $s1, phan phan so vao $s2)----#
 								    
		
Func:
		# Lay gia tri 1 bit dau luu vao $s0
		andi	$s0,$t0,0x80000000
		# Lay gia tri 8 bit so mu luu vao $s1
		andi	$s1,$t0,0x7f800000
		# Lay gia tri 23 bit phan so luu vao $s2
		andi	$s2,$t0,0x007fffff
		# them 1 vao dau de thu duoc phan dinh tri 24bit
		ori	$s2,$s2,0x00800000
#------------------------------end-------------------------------#
	
#------------------Load cac gia tri cua Num2---------------------# 
#----(bit dau vao $s3, phan mu vao $s4, phan phan so vao $s5)----#

		# Lay gia tri 1 bit dau luu vao $s3
		andi	$s3,$t1,0x80000000
		# Lay gia tri 8 bit so mu luu vao $s4
		andi	$s4,$t1,0x7f800000
		# Lay gia tri 23 bit phan so luu vao $s5
		andi	$s5,$t1,0x007fffff
		# them 1 vao dau de thu duoc phan dinh tri 24 bit
		ori	$s5,$s5,0x00800000
#--------------------------END B1--------------------------------#		
		
			
#----------------------------------------------------------------#
#              B2: SO SANH MU VA DICH PHAN SO                    #
#----------------------------------------------------------------#
# Sau khi thuc hien doan code tren:                              #
# Num1: | $s0 | $s1 | $s2 |                                      #
# Num2: | $s3 | $s4 | $s5 |                                      #
# Thuc hien so sanh phan so mu, dich phan phan so cho phu hop    #
# Cong hai phan phan so, chuan hoa                               #
#----------------------------------------------------------------#

#------------So sanh phan mu va dich phan dinh tri---------------#

		# So sanh mu, neu bang nhau thi cong phan dinh tri ngay	
		beq 	$s1,$s4,XetNum1 		
		slt 	$t7,$s1,$s4
		# Neu so mu Num1 < so mu Num2 thi dich phan dinh tri cua Num1
		beq 	$t7,1,DichNum1 
		# Dich Num2
DichNum2: 
		beq 	$s1,$s4,XetNum1 
		# Dich phai phan dinh tri cua Num2
		srl 	$s5,$s5,1
		# phan mu + 1 <=> bit[30:23]+1 -> tuong ung vi tri phan mu
		addi	$s4,$s4,0x00800000	
		j 	DichNum2
		
DichNum1:
		beq 	$s1,$s4,XetNum1 
		# Dich phai phan dinh tri cua Num2
		srl 	$s2,$s2,1
		# phan mu + 1 <=> bit[30:23]+1 -> tuong ung vi tri phan mu
		addi	$s1,$s1,0x00800000	
		j 	DichNum1
						
XetNum1:		# neu s0 = 1 (num1<0) -> doi dau phan dinh tri num1 
		beq	$s0,0,XetNum2
		sub	$s2,$zero,$s2  		
XetNum2:	
		# neu s3 = 1 (num2<0) -> doi dau phan dinh tri num2 	
		beq	$s3,0,Congdinhtri
		sub	$s5,$zero,$s5					
					
#--------------------------------end-----------------------------#
			
									
#------------------Cong hai phan dinh tri------------------------#
#------- lay 24 bit thap luu vao $s6, phan mu luu vao $t8 -------#
# Tham so $a0 = $s2 + $s5// $a0 = $s2- $s5 (phan dinh tri)-------#
# Tra ve kq $v0  ------------------------------------------------#

Congdinhtri:	
	# Tong/Hieu hai phan dinh tri: $a0 = $s2+$s5 // $s2- $s5
	# Bit dau luu vao $t2
	# $t4: giu so mu de thuc hien tang giam
	# $t8 = Tong	$t9 = Hieu
		
		add	$a0,$s2,$s5
		# Thuc hien phep cong -> KQ = $v0
		jal	Xetdaudinhtri
		#Luu kq vao $t8
		add	$t8,$v0,$zero
		
		# Phep tru 2 dinh tri
		sub	$a0,$s2,$s5
		jal	Xetdaudinhtri
		add	$t9,$v0,$zero
		j	printResult
			
Xetdaudinhtri:
		# Neu dinh tri < 0 -> $t2 = 1 
		slt	$t2,$a0,$zero
		
		# Neu $t2 = 1 -> $a0 < 0 -> $t2 =0x80000000 (bit dau)
		# va doi dau a0 vi a0 > 0
		# $t2 = 0 -> bit dau = $t2 = 0
		beq	$t2,0,KTraDinhTri
		addi	$t2,$zero,0x80000000
		sub	$a0,$zero,$a0
		
KTraDinhTri:
		# Lay ra bit cao nhat cua phan dinh tri -> t7 (overflow)
		srl 	$t7,$a0,24
		# t7 = 1 phan dinh tri 25 bit -> dich phai 24 bit, 
		# lay 24 bit thap lam phan dinh tri
		# dong thoi:  mu-> mu + 1 
		add	$t4,$zero,$s1
		# t7 = 0 tien hanh vong lap -> chuan tac
		beq	$t7,0,Chuantac
		# phan mu + 1 <=> bit[30:23] + 1 
		# -> tuong ung voi vi tri phan mu cua so thuc
		addi	$t4,$t4,0x00800000
		# Dich phan dinh tri qua phai 1 bit
		srl	$a0,$a0,1
		j	GhepKQ
		
Chuantac: 
		srl 	$t7,$a0,23
		beq 	$t7,1,GhepKQ
		# Dich trai phan phan so cua ket qua
		sll 	$a0,$a0,1
		# phan mu - 1 <=> bit[30:23] - 1
		# -> tuong ung voi vi tri phan mu cua so thuc
		subi 	$t4,$t4,0x00800000
		# Kiem tra tiep tuc
		j	Chuantac
GhepKQ:
		# Lay 23 bit thap -> dinh tri cho ket qua
		andi	$v0,$a0,0x007fffff
		# Ghep bit dau ( t2) vao thanh a0
		or	$v0,$v0,$t2
		# ghep 8 bit mu (s1) vao thanh a0 ghi ket qua
		or	$v0,$v0,$t4
		jr	$ra
				
#-----------------------------END B3-----------------------------#


#----------------------------------------------------------------#
#                           HAM MAIN                             #
#----------------------------------------------------------------#
# Input: hai so thuc chinh xac don                               #
# Output: ket qua cong va tru                                    #
#----------------------------------------------------------------#
main:
		# Nhap va gia tri a, luu vao Num1
		addi	$a0,$zero,0x10010000
		addi	$v0,$zero,4
		syscall
		
		addi	$v0,$zero,6
		syscall
		mfc1	$t0,$f0
		
		# Nhap va gia tri b, luu vao Num2
		addi	$a0,$zero,0x10010011
		addi	$v0,$zero,4
		syscall
		
		addi	$v0,$zero,6
		syscall
		mfc1	$t1,$f0
		j	Func
		
printResult:	
		# Load vao thanh ghi $f12 va goi syscall in ra console
		addi	$a0,$zero,0x10010022
		addi	$v0,$zero,4
		syscall
		
		mtc1	$t8,$f12
		addi 	$v0,$zero,2
		syscall	
		
		addi	$a0,$zero,0x10010032
		addi	$v0,$zero,4
		syscall
		
		mtc1	$t9,$f12
		addi 	$v0,$zero,2
		syscall

##################################################################
####----------------------------------------------------------####
####                     END PROGRAM                          ####
####----------------------------------------------------------####
##################################################################
		
