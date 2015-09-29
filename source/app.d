import std.stdio, std.range, pegged.grammar;

enum ConstraintPeg =
`
Constraint:
	Terms			<- Term eoi
	Term			<- Arithmetic (Comparison / "IS NULL" / "NOT IS NULL" / "IS NOT NULL") (LogicOp Term)?
	Comparison		<  CompareOp Arithmetic
	CompareOp		<- "<>" / "!=" / '=' / '<' / '>'
	LogicOp			<  "AND" / "OR"
	Arithmetic		<- Primary (ArithmeticOp Arithmetic)?
	Primary			<  Parens / Literal / Attribute / Parameter / FuncCall
	Parens			<- "(" (Term / Arithmetic) ")"
	Attribute		<- Symbol '.' Symbol
	Parameter		<- '@' Symbol
	FuncCall		<- Symbol "(" FuncArgs? ")"
	FuncArgs		<- Arithmetic ("," Arithmetic)*
	Symbol			<- !Keyword identifier
	Literal			<  Number / String / "NULL"
	String			<~ "'" Char* "'"
	Char			<- "''" / (!"'" .)
	Number			<~ [0-9]+ ('.' [0-9]+)?
	ArithmeticOp	<  '+' / '-' / '/' / '*'
	Keyword			<- "TRUE" / "FALSE" / "NULL" / "IS" / "AND" / "OR"
`;

mixin(grammar(ConstraintPeg));

void main(string[] args)
{
	foreach(input; args[1 .. $])
	{
		writeln('='.repeat(40));
		writeln("Input: ", input);
		writeln(Constraint(input));
	}
}
