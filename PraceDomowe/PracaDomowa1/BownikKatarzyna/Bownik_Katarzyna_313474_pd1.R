library(dplyr)

df <- read.csv("house_data.csv")


# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?

quality_median <- median(df$grade)

mean_price <- df %>%
  filter(grade >= quality_median, waterfront == 1) %>%
  summarise(mean = mean(price)) %>%
  unlist()

# Odp: 1784152


# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?

df %>%
  group_by(floors) %>%
  summarise(median = median(bathrooms)) %>%
  filter(floors == 2 | floors == 3)

# Odp: Nie


# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?

middle_long <- mean(range(df$long))
middle_lat <- mean(range(df$lat))

how_many <- df %>%
  filter((lat > middle_lat & long < middle_long) | (lat < middle_lat & long > middle_long)) %>%
  mutate(location = ifelse(lat > middle_lat, "NW", "SE")) %>%
  group_by(location) %>%
  summarise(n = n()) 

ratio <- unlist(((how_many[1, 2] - how_many[2, 2])/how_many[2, 2])*100)

# Odp: 18343.53%


# 4. Jak zmienia�a si� (mediana) liczba �azienek dla nieruchomo�ci wybudownych w latach 90 XX wieku wzgl�dem nieruchmo�ci wybudowanych roku 2000?

median1 <- df %>%
  filter(yr_built >= 1990, yr_built <= 1999) %>%
  summarise(median = median(bathrooms)) %>%
  unlist()

median2 <- df %>%
  filter(yr_built == 2000) %>%
  summarise(median = median(bathrooms)) %>%
  unlist()

# Odp: Nie zmieni�a si�


# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?

df %>% 
  filter(lat > middle_lat) %>%
  group_by(waterfront) %>%
  summarise(qt_25 = quantile(grade)[2], gt_75 = quantile(grade)[4])


# Odp: Je�eli jest nad wod�, to kwartyl 0.25 = 8, kwartyl 0.75 = 10, je�eli nie jest nad wod�, to kwartyl 0.25 = 7, kwartyl 0.75 = 8.


# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?

zipcode1 <- df %>% 
  group_by(zipcode) %>%
  summarise(n = n()) %>%
  top_n(1, n) %>%
  select(zipcode) %>%
  unlist()

iqr <- df %>%
  filter(zipcode == zipcode1) %>%
  summarise(iqr = IQR(price)) %>%
  unlist()


# Odp: Kod pocztowy: 98103, rozst�p mi�dzykwartylowy: 262875.


# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?

ratio <- df %>%
  mutate(is_higher = ifelse(sqft_living15 > sqft_living, "yes", "no")) %>%
  group_by(is_higher) %>%
  summarise(n = n()) %>%
  mutate(ratio = (n/sum(n))*100) %>%
  filter(is_higher == 'yes') %>%
  select(ratio) %>%
  unlist()

# Odp: 42.6%


# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dne) oraz zosta�y zbudowane po 1970?

df %>%
  filter(price > quantile(price)[4], yr_renovated >= 2012, yr_built >= 1970) %>%
  group_by(bedrooms) %>%
  summarise(n = n())


# Odp: 4 z 3 pokojami, 2 z 4 pokojami i 1 z 5 pokojami.


# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).

q_25 <- quantile(df$sqft_living)[2]
q_75 <- quantile(df$sqft_living)[4]
iqr <- IQR(df$sqft_living)

outliers <- df %>%
  filter(((sqft_living < q_25 - 1.5*iqr) | (sqft_living > q_75 + 1.5*iqr)) & ((sqft_living >= q_25 - 3*iqr) | (sqft_living <= q_75 + 3*iqr))) %>%
  summarise(n = n()) %>%
  unlist()

# Odp: 572


# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.

top_price <- df %>%
  mutate(sqm = sqft_living/(10.764)) %>%
  mutate(price_per_sqm = price/sqm) %>% 
  select(price_per_sqm) %>%
  top_n(1, price_per_sqm) %>%
  unlist()

# Odp: 8720.335