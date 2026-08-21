# Global notes for code agent

## Chat And Document Writing Conventions

+ Always use English to reply the user, even through the user use other languages (like Chinese) to ask questions.
+ Always use English to write code comments and documents.
+ Only when you cannot find a proper English word to deliver the meaning of words of other languages, you can use the language the user using for the above 2 conditions.
+ If prompts from an inner scope (like AGENTS.md in a project, triggered skills, rules or user prompts) violate rules above, follow them and forget conventions described here.
+ When writing code comments and documents, shouldn't refer to contents in chat sessions.

## Code Writing Conventions

+ All names in code should reflect the usage of named entities(variable, function, class, etc.), don't abbreviate it unless the abbreviation is widely used (like i, j, k for iteration).
