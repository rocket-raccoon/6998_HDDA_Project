#Dependencies
from selenium import webdriver
from datetime import timedelta
from bs4 import BeautifulSoup
import dateutil.parser
import csv

class currency_scraper():
    
    #Set the url we want to scrape data from
    url = "http://www.xe.com/currencytables/?from=USD&date=%s"
    driver = None
    dates = None    
    scraped_data = None    
    
    #Fire up the virtual web browser
    def initialize_browser(self):
        fp = webdriver.FirefoxProfile()
        driver = webdriver.PhantomJS()
        self.driver = driver
    
    #Set the dates we want to scrape currency data for
    def set_date_intervals(self, start_date, end_date, num_periods):
        start_date = dateutil.parser.parse(start_date)
        end_date = dateutil.parser.parse(end_date)
        num_days_in_period = (end_date-start_date).days / num_periods
        dates = []
        cur_date = start_date
        while(cur_date < end_date):
            date = cur_date.strftime("%Y-%m-%d")
            dates.append(date)
            cur_date = cur_date + timedelta(days=num_days_in_period)
        self.dates = dates
    
    #Scrape data
    def scrape_currency_data(self):
        
        def parse_currency_from_html(html):
            data = []
            soup = BeautifulSoup(html)
            rows = soup.find('table', {'id': 'historicalRateTbl'}).find('tbody').findAll('tr')
            for row in rows:
                currency_code = row.td.text
                price = row.td.findNextSibling().findNextSibling().findNextSibling().text
                data.append([currency_code, price])
            return data
        
        def add_row(data, cur_data, date):        
            #Add the headers if it hasnt already been done
            if not data:
                headers = ["Date"] + [row[0] for row in cur_data]        
                data.append(headers)
            #Add the date first
            new_row = []
            new_row.append(date)
            #Add the prices for everything else
            new_row = new_row + [row[1] for row in cur_data]
            data.append(new_row)
            return data
        
        data = []
        driver = self.driver
        for date in self.dates:
            driver.get(self.url%(date))
            html = driver.page_source            
            cur_data = parse_currency_from_html(html)
            data = add_row(data, cur_data, date)
        self.scraped_data = data
    
    #Outputs the scraped data to csv format
    def output_to_csv(self, outfile):
        scraped_data = self.scraped_data
        if scraped_data:
            f = open(outfile, "wb")
            fileWriter = csv.writer(f, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            for row in scraped_data:
                fileWriter.writerow(row)            
        else:
            raise "No scraped data to output"

#Run the scraper when ran from the command line
if __name__ == "__main__":
    scraper = currency_scraper()
    try:
        scraper.initialize_browser()
        scraper.set_date_intervals("2013-01-01", "2014-01-01", 20)
        scraper.scrape_currency_data()
    except:
        raise "Scraper failed to complete"
    if scraper.driver:
        scraper.driver.quit()
    scraper.output_to_csv("currency_data.csv")
    


   
