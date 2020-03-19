* Import author characteristics.
odbc_compress, exec("SELECT * FROM AuthorCorr NATURAL JOIN Author;") dsn(Strumia)

* Drop article gender of at least one author is not defined.
tempvar null nulldrop
generate `null' = missing(Gender)
by ArticleID, sort: egen `nulldrop' = max(`null')
drop if `nulldrop'==1
drop `null' `nulldrop'

* Calculate gender ratio of authors by article.
generate Female = Gender=="Female"
collapse (mean) FemRatio=Female (count) N=AuthorID (sum) FemN=Female, by(ArticleID)
generate ManN = N - FemN
tempfile sex
save `sex'

* Generate journal rank (number of articles in the database published in a particular journal).
odbc_compress, exec("SELECT * FROM JournalCorr;") dsn(Strumia)
collapse (count) JnlRank=ArticleID, by(JournalID)
tempfile jnlrank
save `jnlrank'

* Keep only the highest ranked journal if an article is published in multiple journals.
odbc_compress, exec("SELECT * FROM JournalCorr;") dsn(Strumia)
merge m:1 JournalID using `jnlrank', assert(match) nogenerate
tempvar max id
by ArticleID, sort: egen `max' = max(JnlRank)
by ArticleID JnlRank, sort: generate `id' = _n
keep if `max'==JnlRank & `id'==1
drop `max' `id'
tempfile journal
save `journal'

* Generate a variable defining author experience (total number of publications at the time of publication)
odbc_compress, exec("SELECT AuthorID, ArticleID, PubDate FROM Article NATURAL JOIN AuthorCorr;") dsn(Strumia)
merge m:1 ArticleID using `journal', keep(match) nogenerate
by AuthorID, sort: generate T = _N
by AuthorID, sort: egen MinPubDate = min(PubDate)
collapse (max) maxT=T (min) MinPubDate, by(ArticleID)
tempfile experience
save `experience'

* Get article data and merge with author sex, journal and experience.
odbc_compress, exec("SELECT ArticleID, PubDate, arXivDate, AuthorN, RefN, Cite, PageRank, PageRankNoSelf, iCite FROM Article;")
merge 1:1 ArticleID using `sex', keep(match) nogenerate
merge 1:1 ArticleID using `journal', keep(match) nogenerate
merge 1:1 ArticleID using `experience', assert(using match) keep(match) nogenerate

generate PubYear = round(PubDate)
generate MinPubYear = round(MinPubDate)
generate arXivYear = round(arXivDate)
generate asinhCite = ln(Cite + sqrt(1 + Cite^2))
generate asinhiCite = ln(iCite + sqrt(1 + iCite^2))
generate Female = FemRatio>0

label variable PubYear "Year of publication"
label variable MinPubYear "Oldest author first pub. year"
label variable Female "Female author"
label variable FemN "No. InSpire female authors"
label variable maxT "max \(T\)"
label variable AuthorN "\(N\)"

save "data/strumia", replace
