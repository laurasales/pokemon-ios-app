## Tech Test README

Hello, welcome to this iOS Tech Test.

**Purpose of this Technical Test**
This technical test is designed not just to evaluate your coding skills, but to serve as a
foundation for technical discussions during the interview. While the app itself is simple,
how you implement it will help us understand your engineering approach and
decision-making process. We encourage you to treat this as a demonstration of your
capabilities - the code you write will give us talking points to dive deeper into your
engineering knowledge and architectural thinking during the technical interview.

**Marvel App**
You don't need to create the Tech Test from scratch, we have created the basics for
you. The current implementation uses MVP and Clean Architecture with Marvel's API to
show a list of superheroes. However, please note that **the existing code contains
errors and architectural flaws** - we encourage you to refactor, restructure, or
completely change any aspect of the project that you believe could be improved.
The app currently includes an APIClient that attempts to execute an HTTP request, map
the JSON, and show an array of superheroes in a UITableView. You can compile the
app with the latest version of Xcode (no Beta).

**Important Note:** The Marvel API has experienced issues recently. Feel free to use
another API that allows you to demonstrate similar knowledge if you prefer. If the API
fails during review, this will not be held against you, but we will evaluate how you've
implemented error handling.

**Important: Adding the requested features alone is not sufficient.** We want to see
your approach to software engineering, including how you might improve upon existing
code.

**Objectives
Must (These points are mandatory)**
- **Show Hero Detail.** When a user taps on a superhero in the list, we want to
navigate to a new screen showing information about that superhero. You can
display whatever you consider relevant: basic information, comics, series, etc.
This will require creating new HTTP requests using the API endpoints.
- **Pagination.** When reaching the bottom of the superhero list, implement loading
of additional heroes. We want to be able to access the complete list of heroes
through pagination.

**Should (Nice to have)**
- **Search bar.** Add filtering capability to the superhero list through a search bar,
allowing users to find heroes by name.
- **Structured Concurrency.** While not mandatory, we recommend using Swift
Concurrency (async/await) for handling asynchronous operations.
- **SwiftUI.** Consider using SwiftUI for parts of the UI or the entire application if you
prefer.
- **Accessibility.** Implement accessibility features to make the app more inclusive.

**Feel free to:**
- Change the architecture completely
- Replace UITableView with UICollectionView or other UI components
- Add UI improvements or animations
- Implement modern Swift features
- Fix any issues you find in the existing code
- Optimize the build system or project configuration
- Set up CI/CD workflows
- Implement any development infrastructure improvements
- Replace or update dependency management
- Add quality assurance tooling (linting, static analysis, etc.)

**What will we evaluate?**
- Architecture - Feel free to improve or change the current architecture
- Testing - Show us your approach to different types of testing
- SOLID principles - We value clean, maintainable and testable code
- Code organization and readability
- Git practices and documentation
- iOS/Swift best practices
- Security considerations
- Development infrastructure and tooling choices
- Build performance and configuration optimizations

**Important notes:**
- This project should showcase your skills - it's perfectly acceptable to implement
solutions that might seem overengineered for a small app if they demonstrate
your capabilities. Explain your decisions in the README.
- Quality over quantity - we prefer fewer well-implemented features over many
poorly implemented ones.
- Document your thought process - we're interested in both the final result and how
you got there.
- **Only include code that you own and can fully explain.** While we all have
utility classes or code we reuse between projects, make sure you're 100% owner
of any code you include and explain its use in your documentation.
- Comments should be used to document reasoning or decisions for reviewers.
Excessive comments that don't add value or are redundant with self-explanatory
code will be viewed negatively.
- Be prepared to explain any part of your code during the interview. All code you
use may be subject to questions.

**Delivery** Please provide:
- Link to your repository with the implementation or zip file including .git folder
- README explaining your main decisions and approach
- Any additional documentation you consider relevant
