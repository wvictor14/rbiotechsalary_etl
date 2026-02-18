import polars as pl
from pathlib import Path

# Your complete raw job titles (lowercase)
raw_titles = """4
5
account manager
active ingredient technician
ad clinical
analyst
analytical development scientist i
analytical operations manager
application specialist
archivist
assistant scientist
assoc analytical development specialist
associate chemist
associate director
associate director - tech modernization
associate director biostatistics
associate director commercial
associate director data engineering
associate director of bioinformatics
associate director of data science
associate director of marketing
associate director program management hematology
associate director safety lead
associate director validation
associate director, clinical supplies
associate director, computational biology
associate director, engineering
associate director, field medical affairs
associate director, fp&a
associate director, lab operations
associate director, lab operations and facilities
associate director, program management
associate director, quality
associate engineer
associate manager
associate manager ms&t
associate manager precision medicine
associate principal scientist
associate program manager iii
associate research assistant
associate research scientist
associate scientist
associate scientist 2
associate scientist i
associate scientist ii
associate scientist, bio-analytics
associate scientist, qc microbiology
associate specialist
associate vp, research compliance
associte director qa
automation engineer
automation engineer i
automation engineer ii
automation engineer iii
bd manager
biochemist
bioinformatic scientist
bioinformatician
bioinformatics analyst ii
bioinformatics consultant
bioinformatics engineer
bioinformatics engineer i
bioinformatics intern
bioinformatics scientist
bioinformatics scientist customer support
bioinformatics senior associate
bioprocess engineer
biostatistician
biotechnologist associate
business analysis manager
business development associate
car-t operations associate
car-t operator
case analyst
category manager
change qa specialist
clinical data manager
clinical data manager i
clinical laboratory scientist ii
clinical project manager
clinical research assistant ii
clinical science director
clinical scientist
clinical supply chain manager
clinical supply chain specialist
co-op
community lead
computational biologist
core facility manager
corporate counsel
cra
cso
cto
data integrity manager
data scientist ii
data specialist
development rotational associate
development scientist
development scientist ii
digital biomarker scientist / specialist
director
director biology
director consulting
director marketing
director of bioinformatics
director of bioprocess
director of business development
director of commercialization analytics
director of drug development
director of epidemiology
director of medical affairs
director of molecular and cellular pharmacology
director of operational excellence
director of operations
director of research
director of research and development
director regulatory
director, business development
director, clinical pharmacology
director, clinical science
director, commercial operations
director, data management
director, global qa
director, head of department
director, investor relations
director, it solutions & governance
director, pv
director, r&d it
director, regulatory clinical science
director, study quality & compliance leas
director, translational science
director,program project management
discovery sourcing operations specialist
doctoral researcher
downstream manufacturing associate i
engineer ii
engineering manager
entry-level-trainee (elt)
ep mapping specialist
executive director
executive director clinical development
executive director, biometrics
executive director, computational biology
executive director, global regulatory operations
executive institutional specialist
fermentation sr. reseach associate
field application scientist
field application specialist
field reimbursement manager
field service
field service engineer
finance lead
food laboratory specialist 1
founding scientist
functional resourcing
general counsel
global product manager
global program leader
graduate
graduate intern
graduate intern (phd)
graduate scientist
graduate student - biochemistry
group head patient safety and risk management
group lead, principal scientist
hardware verification specialist
head of r&d operations
health science administrator
hourly
hpc engineer
human resources manager
industry career advisor
infectious disease co-op
instruments engineer
intern
junior trainee
lab analyst
lab automation engineer
lab manager
lab specialist
lab specialist intermediate
lab tech
lab technician
lab technician ii
laboratory engineer ii
laboratory operations manager
laboratory technician ii
lead engineer
lead ops tech
life science consultant
lims manager
machine learning lead
machine learning scientist
machine learning scientist and engineer
machine learning scientist, head of bioinformatics
manager
manager / principal scientist equivalent
manager biostatistics
manager it pmo
manager of regulatory ad promo
manager, clinical qa
manager, clinical systems
manager, operations
manager, qa
manager, quality assurance
manufacturing associate
manufacturing associate ii
manufacturing manager ii
manufacturing senior lead investigator
marketing manager
medical affairs and communications lead
medical affairs trainee
medical director, clinical development
medical science liaison
method validation specialist
molecular genetics technologist
molecular technologist
msat engineer ii
necropsy team leader
onsite support
pharmacokineticist
phd student
post master
post-doctoral research associate
postdoc
postdoctoral associate
postdoctoral fellow
principal associate scientist
principal clinical imaging scientist
principal computational biologist
principal data scientist
principal engineer
principal health economist
principal machine learning scientist
principal process development engineer
principal process engineer
principal product manager
principal research associate
principal research scientist
principal research scientist i
principal scientist
principal scientist (translational science lead)
principal scientist process chemistry
principal software engineer
principle scientist
process development associate scientist
process development engineer ii
process development engineer iii
process development rotation program (pdrp) associate
process development scientist
process development senior scientist
process development sr. associate
process engineer ii
process engineer ii, msat
procurement director
product applications specialist
product launch specialist
product manager
product scientist
product support manager
production associate
production planning manager- clinical manufacturing
production specialist
production supervisor
professor
program management and alliance manager
program management director
program manager
project leader
project management intern
project manager
project manager ii
proposal manager
prospecting, petroglyphs, ancient symbols,
qa engineer
qa manager
qc analyst ii
qc development scientist i
qc engineer l
qc scientist
quality assurance manager
quality assurance senior technician
quality assurance specialist
quality control manager
quality control microbiology lead specialist
quality control supervisor
quality engineering manager
quality regulatory compliance specialist
quality systems lead
quality validation manager
r&d specialist
r&d strategic projects operations lead
regulatory affairs manager
research assistant
research assistant (bioinformatician)
research assistant i
research assistant iii
research associate
research associate (engineer)
research associate 2
research associate i
research associate ii
research associate iii
research lab manager
research officer
research professional
research professional iii
research scientist
research scientist i
research scientist ii
research scientists i
research support specialist
research technician
researcher
researcher iv
safety manager
salaried
sample management (contractor)
scientific lead
scientific marketing officer
scientist
scientist 1
scientist 2
scientist 3
scientist i
scientist ii
scientist ii, lead
scientist iii
scientist iii, molecular biology
scientist ll
scientist, engineering
scientist, molecular biology
scientists technical support
senior accounting manager
senior applied research scientist
senior applocations scientist
senior associate
senior associate scientist
senior associate scientist ii
senior associate, qc
senior bioinformatician
senior bioinformatics engineer
senior bioinformatics scientist
senior bioinformatics scientist 2
senior chemist
senior clinical laboratory scientist
senior clinical project manager
senior clinical scientist
senior cmc project manager
senior computational associate
senior computational biologist
senior consultant
senior csv engineer
senior data scientist
senior director
senior director global market access
senior director of bioinformatics
senior director program management
senior director, clinical data management
senior director, program management
senior downstream process technician
senior engineer
senior engineer ii
senior engineering manager
senior field applications scientist
senior human resources generalist
senior laboratory analyst
senior laboratory technician
senior manager
senior manager drug safety & pharmacovigilance operations
senior manager engineering
senior manager medical writing
senior manager quality systems
senior manager, business analytics
senior manager, clinical data management
senior manager, cold chain logistics
senior manager, operations
senior manager, quality systems
senior manufacturing associate
senior manufacturing scientist
senior manufacturing technology engineer
senior medical director
senior oncology specialist
senior principal scientist
senior principal scientist - msat
senior process chemist
senior process development associate
senior process engineer
senior process engineer iii
senior process maintenance
senior product engineer
senior program and alliance manager
senior quality engineer
senior regulatory affairs associate
senior research associate
senior research associate 2
senior research associate i
senior research associate, analytical development
senior research associate, platform development
senior research scientist
senior research support associate
senior scientific project manager
senior scientist
senior scientist 1
senior scientist and team lead
senior scientist i
senior scientist i, medicinal chemistry
senior scientist ii
senior scientist ii process development
senior scientist in computational biology
senior scientist, cadd
senior scientist, computational biology
senior scientist, r&d
senior scientist- packaging
senior scietist
senior software developer
senior specialist
senior specialist, engineering
senior staff bioinformatics engineer
senior technician
senior toxicologist
site specialist
sma i
software engineer
software engineer 3
specialist engineering
specialist iii
specialist, it security
sr analyst
sr analytical engineer
sr cheminformatics scientist
sr clinical scientist
sr manager raw supply chain
sr msl
sr program manager
sr qa associate ii
sr quantitative pharmacologist
sr scientist
sr scientist i
sr staff s&op manager
sr. associate scientist
sr. cell culture technician
sr. data scientist
sr. director of antibody engineering
sr. manager tsms
sr. manager, ms&t
sr. manufacturing associate
sr. medical science liaison
sr. principal scientist
sr. product marketing manager
sr. qa specialist ops
sr. research associate
sr. scientist
sr. specialist
sr. supply chain specialist
staff clinical research scientist
staff data scientist
staff engineer
staff engineer, msat
staff process engineer
staff scientist
staff scientist, bioinformatics
student lab assistant
study manager
study physician
study technician iii
supervisor, manufacturing sciences and technology
supply chain manager
support manufacturing associate 1
systems engineer iii
talent aquisition
team leader
technical applications scientist 2
territory account manager
therapeutic specialist
toxicologist
validation engineer
validation engineer manager
validation specialist
vice president, business development
vp
vp medical affairs
vp r&d
vp technical development & manufacturing
vp, transformation""".strip().split('\n')
import polars as pl
from pathlib import Path
import re

# Your complete raw job titles (lowercase) - keep as is

# Define standardization rules
standardization_map = {
    # Garbage/unknowns
    '4': 'Unknown',
    '5': 'Unknown',
    'hourly': 'Unknown',
    'salaried': 'Unknown',
    'co-op': 'Unknown',
    'functional resourcing': 'Unknown',
    'onsite support': 'Unknown',
    'prospecting, petroglyphs, ancient symbols,': 'Unknown',
    'talent aquisition': 'Unknown',
    
    # Typos - fix misspellings
    'associte director qa': 'Associate Director QA',
    'senior scietist': 'Senior Scientist',
    'senior applocations scientist': 'Senior Applications Scientist',
    'fermentation sr. reseach associate': 'Fermentation Senior Research Associate',
    'principle scientist': 'Principal Scientist',
    'director, study quality & compliance leas': 'Director, Study Quality & Compliance Lead',
    'qc engineer l': 'QC Engineer I',
    'scientist ll': 'Scientist II',
    
    # Standardize abbreviations to full titles
    'cra': 'Clinical Research Associate',
    'cso': 'Chief Scientific Officer',
    'cto': 'Chief Technology Officer',
    'bd manager': 'Business Development Manager',
    
    # Expand common abbreviations in titles
    'sr. associate scientist': 'Senior Associate Scientist',
    'sr. cell culture technician': 'Senior Cell Culture Technician',
    'sr. data scientist': 'Senior Data Scientist',
    'sr. director of antibody engineering': 'Senior Director of Antibody Engineering',
    'sr. manager tsms': 'Senior Manager TSMS',
    'sr. manager, ms&t': 'Senior Manager, Manufacturing Science & Technology',
    'sr. manufacturing associate': 'Senior Manufacturing Associate',
    'sr. medical science liaison': 'Senior Medical Science Liaison',
    'sr. principal scientist': 'Senior Principal Scientist',
    'sr. product marketing manager': 'Senior Product Marketing Manager',
    'sr. qa specialist ops': 'Senior QA Specialist Ops',
    'sr. research associate': 'Senior Research Associate',
    'sr. scientist': 'Senior Scientist',
    'sr. specialist': 'Senior Specialist',
    'sr. supply chain specialist': 'Senior Supply Chain Specialist',
    'sr analyst': 'Senior Analyst',
    'sr analytical engineer': 'Senior Analytical Engineer',
    'sr cheminformatics scientist': 'Senior Cheminformatics Scientist',
    'sr clinical scientist': 'Senior Clinical Scientist',
    'sr manager raw supply chain': 'Senior Manager Raw Supply Chain',
    'sr msl': 'Senior Medical Science Liaison',
    'sr program manager': 'Senior Program Manager',
    'sr qa associate ii': 'Senior QA Associate II',
    'sr quantitative pharmacologist': 'Senior Quantitative Pharmacologist',
    'sr scientist': 'Senior Scientist',
    'sr scientist i': 'Senior Scientist I',
    'sr staff s&op manager': 'Senior Staff S&OP Manager',
    
    # Standardize common abbreviation patterns
    'assoc analytical development specialist': 'Associate Analytical Development Specialist',
    
    # Handle case inconsistencies and variants
    'ad clinical': 'Associate Director Clinical',
}

def format_job_title(title):
    """
    Standardize job title:
    1. Apply mapping rules
    2. Title case the result
    3. Fix roman numerals (i->I, ii->II, iii->III, iv->IV)
    4. Capitalize specific abbreviations (vp->VP, qa->QA, r&d->R&D, etc.)
    5. Fix spacing after commas
    6. Convert numbered scientists (scientist 1 -> Scientist I, scientist 2 -> Scientist II, etc.)
    """
    # Apply initial mapping
    title = standardization_map.get(title, title)
    
    # Title case
    title = title.title()
    
    # Fix roman numerals (must be after title case)
    title = re.sub(r'\bI\b(?![\w&])', 'I', title)  # single I
    title = re.sub(r'\bIi\b', 'II', title)  # ii -> II
    title = re.sub(r'\bIii\b', 'III', title)  # iii -> III
    title = re.sub(r'\bIv\b', 'IV', title)  # iv -> IV
    
    # Fix specific abbreviations
    abbreviations = {
        'Vp': 'VP',
        'Qa': 'QA',
        'Qc': 'QC',
        'R&d': 'R&D',
        'Cra': 'CRA',
        'Cso': 'CSO',
        'Cto': 'CTO',
        'Ms&t': 'MS&T',
        'Msat': 'MSAT',
        'Fp&a': 'FP&A',
        'Pdrp': 'PDRP',
        'Cadd': 'CADD',
        'Lims': 'LIMS',
        'Hpc': 'HPC',
        'It': 'IT',
        'Pv': 'PV',
        'S&op': 'S&OP',
        'Tsms': 'TSMS',
        'Elt': 'ELT',
        'Phd': 'PhD',
    }
    
    for wrong, correct in abbreviations.items():
        title = re.sub(rf'\b{wrong}\b', correct, title)
    
    # Fix spacing after commas
    title = re.sub(r',(\S)', r', \1', title)
    
    # Convert numbered scientists (scientist 1 -> Scientist I, etc.)
    title = re.sub(r'\bScientist 1\b', 'Scientist I', title)
    title = re.sub(r'\bScientist 2\b', 'Scientist II', title)
    title = re.sub(r'\bScientist 3\b', 'Scientist III', title)
    title = re.sub(r'\bAssociate Scientist 2\b', 'Associate Scientist II', title)
    title = re.sub(r'\bSenior Scientist 1\b', 'Senior Scientist I', title)
    title = re.sub(r'\bSenior Bioinformatics Scientist 2\b', 'Senior Bioinformatics Scientist II', title)
    title = re.sub(r'\bResearch Associate 2\b', 'Research Associate II', title)
    title = re.sub(r'\bSenior Research Associate 2\b', 'Senior Research Associate II', title)
    title = re.sub(r'\bSma I\b', 'SMA I', title)
    
    return title

# Create DataFrame from raw titles
df_raw = pl.DataFrame({'raw_job_title': raw_titles}).unique()

# Apply formatting
df_standardized = df_raw.with_columns(
    pl.col('raw_job_title')
    .map_elements(format_job_title, return_dtype=pl.Utf8)
    .alias('standardized_job_title')
).select(['raw_job_title', 'standardized_job_title']).sort('standardized_job_title')

# Write to seed file
output_path = Path('seeds') / 'job_titles.csv'
df_standardized.write_csv(output_path)

df_standardized