import os
import time
import json
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

# Read the input from json
json_data = open("config.json").read()
json_object = json.loads(json_data)

# Get the path of ChromeDriverServer
#dir = os.path.dirname(__file__)          //Default path
chrome_driver_path = "chromedriver.exe"
browser_site_name = json_object["WebSite"][0]["SiteName"]
# Get the website name 
print("Site Name: " + browser_site_name + "/ap/frmLogin.aspx")
# Get the publish key 
#publish_key = 

# create a new Chrome session
driver = webdriver.Chrome(chrome_driver_path)
driver.implicitly_wait(30)
driver.maximize_window()

# Navigate to the application home page
driver.get("http://" + browser_site_name + "/ap/frmLogin.aspx")

# get the search textbox
search_field = driver.find_element_by_id("txtUserName").send_keys("obadmin")
search_field = driver.find_element_by_id("txtPsswrd").send_keys("admin123")

# enter search keyword and submit
search_field = driver.find_element_by_id("userEntry_imgLogin").click()
time.sleep(10)
search_field = driver.find_element_by_css_selector("#cphPageContent_blstTrnsctn > li:nth-child(2) > a").click()
time.sleep(10)
search_field = driver.find_element_by_id("cphPageContent_cphQueryPanelContent_ucPblshFtreCntrl_ddlPlan").send_keys("OB iCRM + iLekha")
time.sleep(10)
search_field = driver.find_element_by_id("cphPageContent_cphQueryPanelContent_ucPblshFtreCntrl_lnkFetch").click()
time.sleep(10)
search_field = driver.find_element_by_id("cphPageContent_cphQueryPanelContent_ucPblshFtreCntrl_lnkPblshForAdminUsers").click()

try:
      element = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, 'updateImg')))
      print("Publish feature done")
except TimeoutError:
      print("Publish feature getting too much time")      
finally:
      time.sleep(5)
      search_field = driver.find_element_by_id("lnkLogout").click()
      time.sleep(5)
      driver.quit()    
