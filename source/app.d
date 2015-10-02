import std.stdio, std.range, pegged.grammar;

enum ConstraintPeg =
`
Constraint:
	Root			<  Expression eoi
	Expression		<  Equality (And / Or)*
	Equality		<  Not? Exists? Term Equals?
	Equals			<  ("<>" / "!=" / "<=" / ">=" / "<" / ">" / "=" / ;Is / ;Like) Term
	Is				<~ [Ii][Ss]
	Like			<~ [Ll][Ii][Kk][Ee]
	Not				<~ [Nn][Oo][Tt]
	Exists			<~ [Ee][Xx][Ii][Ss][Tt][Ss]
	Term			<  Factor (Add / Sub)*
	Add				<  "+" Factor
	Sub				<  "-" Factor
	And				<  ~([Aa][Nn][Dd]) Equality
	Or				<  ~([Oo][Rr]) Equality
	Factor			<  Primary (Mul / Div)*
	Mul				<  "*" Primary
	Div				<  "/" Primary
	Primary			<  Parens / Neg / Cast / FuncCall / Constant
	Parens			<  "(" Expression ")"
	Neg				<  "-" Primary
	Cast			<- [Cc][Aa][Ss][Tt] "(" Primary [Aa][Ss] DataType ")"
	DataType		<  ("varchar(" Number ")")
	FuncCall		<- Symbol ("." Symbol)? "(" FuncArgs? ")"
	FuncArgs		<  Expression (',' Expression)*
	Constant		<  Parameter / Attribute / Number / String / Null / True / False / Symbol
	Parameter		<~ "@" Symbol
	Attribute		<- (QueryNode / Symbol) "." Symbol
	Number			<~ [0-9]+ ('.' [0-9]+)?
	String			<~ "'" Char* "'"
	Char			<- "''" / (!"'" .)
	QueryNode		<~ '[' Hex4Byte '-' Hex2Byte '-' Hex2Byte '-' Hex2Byte '-' Hex6Byte ']'
	Hex6Byte		<~ Hex4Byte Hex2Byte
	Hex4Byte		<~ Hex2Byte Hex2Byte
	Hex2Byte		<~ HexByte HexByte
	HexByte			<~ HexDigit HexDigit
	HexDigit		<- [0-9a-fA-F]
	Symbol			<  identifier
	Null			<~ [Nn][Uu][Ll][Ll]
	True			<~ [Tt][Rr][Uu][Ee]
	False			<~ [Ff][Aa][Ll][Ss][Ee]
`;

mixin(grammar(ConstraintPeg));

void main(string[] args)
{
	foreach(input; args[1..$])
	{
		writeln('='.repeat(40));
		writeln("Input: ", input);
		writeln(Constraint(input));
	}
}
