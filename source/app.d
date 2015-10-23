import std.algorithm, std.stdio, std.range, std.array, pegged.grammar;

mixin(grammar(import("Constraint.grammar")));

void main(string[] args)
{
	auto inputs = args.length > 1
		? args[1 .. $]
		: File("Constraints.txt").byLineCopy.array;

	foreach(input; args[1 .. $])
	{
		auto result = Constraint(input);
		
		if(args.length == 1 && result.successful) continue;
	
		writeln('='.repeat(40));
		writeln("Input: ", input);
		writeln(result);
	}
}
