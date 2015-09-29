import std.stdio, std.range, pegged.grammar;

enum ConstraintPeg =
`
Constraint:
	Terms			<- Term eoi
	Term			<- Arithmatic (Comparison / "IS NULL" / "NOT IS NULL" / "IS NOT NULL") (LogicOp Term)?
	Comparison		<  CompareOp Arithmatic
	CompareOp		<- "<>" / "!=" / '=' / '<' / '>'
	LogicOp			<  "AND" / "OR"
	Arithmatic		<- Primary (ArithmaticOp Arithmatic)?
	Primary			<  Parens / Literal / Attribute / Parameter / FuncCall
	Parens			<- "(" (Term / Arithmatic) ")"
	Attribute		<- Symbol '.' Symbol
	Parameter		<- '@' Symbol
	FuncCall		<- Symbol "(" FuncArgs? ")"
	FuncArgs		<- Arithmatic ("," Arithmatic)*
	Symbol			<- identifier
	Literal			<  Number / String
	String			<~ "'" Char* "'"
	Char			<- "''" / (!"'" .)
	Number			<~ [0-9]+ ('.' [0-9]+)?
	ArithmaticOp	<  '+' / '-' / '/' / '*'
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