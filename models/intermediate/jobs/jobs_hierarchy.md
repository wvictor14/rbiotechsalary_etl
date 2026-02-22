{% docs jobs_hierarchy %}

## Job Hierarchy Mapping

### 1. Approach Overview

This model uses a Priority-Based Fuzzy Heuristic to map messy, free-text job titles to a structured corporate hierarchy. It solves the "partial match" problem (e.g., distinguishing between an "Associate" and an "Associate VP") by ranking potential matches based on specificity and importance.

### 2. Logical Steps

- Normalization: Deduplicates raw titles and joins with job_titles to get a "Clean Title."

- Sanitization: Strips commas and slashes in title_to_match_on to prevent punctuation from breaking the word-boundary search.

- The Fuzzy Join: Matches keywords using a 4-point check (Exact, Starts-with, Ends-with, or Surrounded-by-spaces). This ensures keywords aren't matched in the middle of other words (e.g., "Analyst" won't match "Psychoanalyst").

- Conflict Resolution (match_rank): * Priority: Matches are sorted by the priority column (1 = Highest).

- Specificity: If priorities tie, the longer keyword wins (e.g., "Senior Scientist" wins over "Scientist").

### 3. Maintenance: Adding New Jobs

1. When a title returns NULL or maps incorrectly, update the job_hierarchy.csv seed:
2. To fix a NULL: Add a unique "stem" word from the title (e.g., toxicologist) as a new keyword.
3. To fix a Misclassification: Adjust the priority. Specific roles (e.g., Associate VP) must have a lower number (higher priority) than generic modifiers (e.g., Associate).

#### Formatting Rules: 

1.  Keywords must be lowercase.
2.  Keywords must not contain punctuation.
3.  Avoid trailing spaces in the CSV.
4. Key Hierarchy Levels

| Hierarchy | PriorityRange | Roles | x | x | x |
|---|---|---|---|---|---|
|  C-Suite/Executive  |  1 – 4  |  "CSO  |   CTO  |   VP  |   Executive Director"  |
|  Management  |  5 – 12  |  "Director  |   Senior Manager  |   Manager"  |    |
|  Professional  |  15 – 18  |  "Scientists  |   Engineers  |   MSLs  |   Analysts"  |
|  Associate/Support  |  20 – 21  |  "Research Associates  |   Manufacturing Associates  |   Techs"  |    |
|  Training  |  25 – 27  |  "Postdocs  |   Interns  |   Ph.D. Students"  |    |



{% enddocs %}