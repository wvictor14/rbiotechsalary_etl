Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


# Project generation

1. run `sanitize_headers.py` 
2. upload `sanitizied.csv` to databricks under rbiotechsalary.sources named as `src_responses`
3. Run `dbt run-operation generate_base_model --args '{"source_name": "survey_results", "table_name": "src_responses"}'` to generate base model, goes in `_stg_responses.sql`
4. 