SELECT titolo, abstract, content_fields_match.value FROM news
LEFT JOIN content_fields_match ON news.id=content_fields_match.id_news
WHERE news.keyword='lista-tamponi'
AND content_fields_match.id_field=1;

UPDATE news AS n
LEFT JOIN content_fields_match as c
ON c.id_news = n.id
SET n.titolo = CONCAT(n.titolo,' - ',c.value) 
WHERE n.keyword='lista-tamponi'
AND c.id_field=1;

UPDATE news
SET abstract = titolo
WHERE news.keyword = 'lista-tamponi';