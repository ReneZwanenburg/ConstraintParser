import std.algorithm, std.conv, std.stdio, std.range, std.array, pegged.grammar;

mixin(grammar(import("Constraint.grammar")));


ParseTree uniAlphaNum(ParseTree p)
{
	enum longname = "an unicode alphanumeric character";
	
	auto input = p.input[p.end .. $];
	
	if (!input.empty)
	{
		auto front = input.front;
		
		import std.uni : isAlpha, isNumber;
		
		if(front.isAlpha || front.isNumber)
		{
			auto poppedInput = input;
			poppedInput.popFront;
			auto numCodeUnits = input.length - poppedInput.length;
			
			return ParseTree("uniAlphaNum", true, [input[0 .. numCodeUnits]], p.input, p.end, p.end+numCodeUnits);
		}
	}
	
	return ParseTree("uniAlphaNum", false, [longname], p.input, p.end, p.end);
}

void main(string[] args)
{
	auto readFromFile = args.length == 1;

	auto constraints = readFromFile
		? File("AllConstraints.txt").byLineCopy.array
		: args[1 .. $];

	foreach(input; constraints)
	{
		auto result = Constraint(input);
		
		if(result.successful && readFromFile) continue;
		
		result.toAst();
		result.visit(&fixNullableComparisons);
	
		//writeln('='.repeat(40));
		writeln(input);
		if(!readFromFile) writeln(result);
	}
}

struct Attribute
{
	string name;
	bool nullable;
}

void visit(ref ParseTree tree, bool function(ref ParseTree node) visitor, string nodeName = null)
{
	if(nodeName.length == 0 || tree.name == nodeName)
	{
		if(!visitor(tree)) return;
	}
	
	foreach(ref child; tree.children)
	{
		child.visit(visitor);
	}
}

bool fixNullableComparisons(ref ParseTree node)
{
	writeln("visiting");
	if(node.name != "Constraint.ValueComparisonPred") return true;
	
	auto v1 = node.children[0];
	auto op = node.children[1];
	auto v2 = node.children[2];
	
	if(v1.name != "Constraint.Attribute" || v2.name != "Constraint.StringLiteral") return true;
	
	writeln("continuing");
	
	if((op.matches[0] == "<>" || op.matches[0] == "!="))
	{
		if(v2.matches[0] != "''")
		{
			writeln("rewriting");
			writeln("(" ~ node.stringify ~ " OR " ~ v1.stringify ~ " IS NULL)");
			node = Constraint("(" ~ node.stringify ~ " OR " ~ v1.stringify ~ " IS NULL)");
			node.toAst();
		}
	}
	
	return false;
}

bool canFindPattern(ParseTree tree)
{
	bool match(ParseTree pt)
	{
		if(pt.name == "Constraint.MonadicBoolOperator")
		{
			auto vcp = pt.children[1];
			if(vcp.name == "Constraint.ValueComparisonPred")
			{
				if(vcp.children[0].name == "Constraint.Attribute" && vcp.children[1].matches[0] == "=" && vcp.children[2].name == "Constraint.StringLiteral")
				{
					return true;
				}
			}
		}
		
		return pt.children.any!match;
	}
	
	return match(tree);
}

string stringify(ParseTree tree)
{
	return tree.matches.join ~ tree.children.map!(a => a.stringify).join;
}

void toAst(ref ParseTree tree)
{
	foreach(ref child; tree.children)
	{
		toAst(child);
	}

	if(tree.children.count == 1)
	{
		tree = tree.children[0];
	}
}
