library(dplyr)

df <- read.csv("house_data.csv")


# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?

df %>% 
  filter(grade >= median(grade, na.rm = TRUE)) %>% 
  filter(waterfront == 1) %>% 
  summarise(mean_price = mean(price, na.rm = TRUE))

# Odp: 1784152


# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?

df %>% 
  filter(floors == 2) %>% 
  summarise(med_2 = median(bathrooms, na.rm = TRUE))

df %>% 
  filter(floors == 3) %>% 
  summarise(med_3 = median(bathrooms, na.rm = TRUE))

# Odp: Nie, maj� tyle samo (2.5)


# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?

A <- df %>% 
     mutate(med_lat = median(lat), med_long = median(long)) %>% 
     filter(lat > med_lat & long < med_long) %>% 
     summarise(n())

B <- df %>% 
     mutate(med_lat = median(lat), med_long = median(long)) %>% 
     filter(lat < med_lat & long > med_long) %>% 
     summarise(n())

((A-B)/B)*100

# Odp: 0.1478561%


# 4. Jak zmienia�a si� (mediana) liczba �azienek dla nieruchomo�ci wybudownych w latach 90 XX wieku wzgl�dem nieruchmo�ci wybudowanych roku 2000?
df %>% 
  filter(yr_built <= 2000) %>% 
  summarise(med_90 = median(bathrooms, na.rm = TRUE))

df %>% 
  filter(yr_built > 2000) %>% 
  summarise(med_00 = median(bathrooms, na.rm = TRUE))


# Odp: Wzros�a o 0.5


# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?
df %>% 
  filter(lat >= median(lat, na.rm = TRUE)) %>% 
  filter(waterfront == 1) %>% 
  summarise(q_1 = quantile(grade))

df %>% 
  filter(lat >= median(lat, na.rm = TRUE)) %>% 
  filter(waterfront == 0) %>% 
  summarise(q_1 = quantile(grade))

# Odp: Ma widok na morze: 8 i 11, nie ma widoku na morze: 7 i 8


# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?

df %>% 
  group_by(zipcode) %>% 
  summarise(n = n()) %>% 
  arrange(-n) %>% 
  head(1) %>% 
  select(zipcode)

df %>% 
  filter(zipcode == 98103) %>% 
  summarise(iqr = IQR(price))

# Odp: 98103, 262875


# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?

rows <- nrow(df)
df %>% 
  filter(sqft_living15 > sqft_living) %>% 
  summarise(n = n()/rows) 

# Odp: 0.4259473


# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dne) oraz zosta�y zbudowane po 1970?

df %>% 
  filter(price > quantile(price)[4] & 
           yr_renovated >= 2012 & 
           yr_built > 1970) %>% 
  summarise(med = median(bedrooms))

# Odp: 3


# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).

df %>% 
  filter(sqft_living < (quantile(sqft_living)[2] - 1.5*IQR(sqft_living)) | 
         sqft_living > (quantile(sqft_living)[4] + 1.5*IQR(sqft_living))) %>% 
  summarise(n = n())

# Odp: 572


# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.
df %>% 
  mutate(price_per_sqm = price/(sqft_living/(3.2808)^2)) %>% 
  arrange(-price_per_sqm) %>% 
  head(1) %>% 
  select(price_per_sqm)

# Odp: 8720.05