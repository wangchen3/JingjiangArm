(*@CES
Name=ENUMS_TIMEFORMAT
Type=Gvl
TypeGuid=2db5746d-d284-4425-9f7f-2663a34b0ebc
Guid=3fd86c5d-f4c2-4e63-8cc9-6ae2cca08ccd
HasDeclaration=True
HasImplementation=False
*)
{DECLARATION}
//{attribute 'qualified_only'}
//{attribute 'strict'}
TYPE ENUMS_TIMEFORMAT : (
	TIMEFORMAT_NO_HYPHEN		, (* yyyymmddHHMMSS *)
	TIMEFORMAT_HYPHEN_COLON		, (* yyyy-mm-dd HH:MM:SS *)
	TIMEFORMAT_HYPHEN_DOT		, (* yyyy.mm.dd.HHMMSS *)
	TIMEFORMAT_MMDD				, (* mmdd *)
	TIMEFORMAT_MMDDHH			  (* mmddHH *)
);
END_TYPE
{IMPLEMENTATION}
