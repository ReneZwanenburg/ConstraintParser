import std.stdio, std.range, pegged.grammar;

enum ConstraintPeg =
`
Constraint:
	Root			<  Expression eoi
	Expression		<  Equality (And / Or)*
	Equality		<  Term Equals?
	Equals			<  ("<>" / "!=" / "<" / ">" / "=") Expression
	Term			<  Factor (Add / Sub)*
	Add				<  "+" Factor
	Sub				<  "-" Factor
	And				<  ([Aa][Nn][Dd]) Equality
	Or				<  ([Oo][Rr]) Equality
	Factor			<  Primary (Mul / Div)*
	Mul				<  "*" Primary
	Div				<  "/" Primary
	Primary			<  Parens / Neg / FuncCall / Constant
	Parens			<  "(" Expression ")"
	Neg				<  "-" Primary
	FuncCall		<- Symbol "(" FuncArgs? ")"
	FuncArgs		<  Expression (',' Expression)*
	Constant		<  Parameter / Attribute / Number / String
	Parameter		<  "@" Symbol
	Attribute		<- Symbol "." Symbol
	Number			<~ [1-9] [0-9]* ('.' [0-9]+)?
	String			<~ "'" Char* "'"
	Char			<- "''" / (!"'" .)
	Symbol			<  identifier
`;

mixin(grammar(ConstraintPeg));

void main(string[] args)
{
	auto inputs = args[1..$];

	foreach(input; inputs)
	{
		writeln('='.repeat(40));
		writeln("Input: ", input);
		writeln(Constraint(input));
	}
}
