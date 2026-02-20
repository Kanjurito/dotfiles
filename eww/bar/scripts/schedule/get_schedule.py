#!/usr/bin/env python3
import json
import os
import re
from datetime import datetime, timedelta
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- CONFIGURATION ---
# The generic URL that we know works for the current week
GENERIC_URL = "https://all.uddataplus.dk/skema/?id=id_menu_skema#menu_skema:"
# The base for specific date links (for the button and next-week jumps)
BASE_LINK_URL = "https://all.uddataplus.dk/skema/?id=id_menu_skema"
RESOURCE_ID = "99217" 

PROFILE_PATH = "/home/ilyamiro/.mozilla/firefox/21ersfgr.eww-shedule"
CACHE_FILE = os.path.expanduser("~/.cache/eww/schedule/schedule.json")

# GAP CONFIG
PIXELS_PER_MINUTE = 1.2 
MAX_GAP_WIDTH = 200

def get_specific_url(date_obj):
    """Constructs the specific link for the button/next week."""
    date_str = date_obj.strftime("%Y-%m-%d")
    return f"{BASE_LINK_URL}#u:e!{RESOURCE_ID}!{date_str}"

def to_epoch(time_str, date_obj):
    try:
        hour, minute = map(int, time_str.split(':'))
        dt = date_obj.replace(hour=hour, minute=minute, second=0, microsecond=0)
        return int(dt.timestamp())
    except:
        return 0

def extract_lessons_from_group(group, date_obj):
    raw_lessons = []
    processed_data = []
    
    lesson_elems = group.find_elements(By.XPATH, ".//*[local-name()='g'][count(*[local-name()='rect']) > 0]")
    
    def get_y_pos(elem):
        try: return float(elem.find_element(By.TAG_NAME, "rect").get_attribute("y"))
        except: return 0
    lesson_elems.sort(key=get_y_pos)

    for elem in lesson_elems:
        try:
            texts = elem.find_elements(By.TAG_NAME, "text")
            if len(texts) >= 3:
                time_raw = texts[0].text 
                start_str, end_str = time_raw.split('-')
                
                raw_lessons.append({
                    "type": "class", 
                    "time": time_raw,
                    "subject": texts[1].text,
                    "room": texts[2].text,
                    "start": to_epoch(start_str, date_obj),
                    "end": to_epoch(end_str, date_obj)
                })
        except:
            continue

    if not raw_lessons: return []

    for i, lesson in enumerate(raw_lessons):
        processed_data.append(lesson)
        if i < len(raw_lessons) - 1:
            next_lesson = raw_lessons[i + 1]
            gap_seconds = next_lesson['start'] - lesson['end']
            if gap_seconds > 1800: # 30 mins
                gap_minutes = int(gap_seconds / 60)
                width = min(int(gap_minutes * PIXELS_PER_MINUTE), MAX_GAP_WIDTH)
                processed_data.append({
                    "type": "gap",
                    "width": width, 
                    "desc": f"{gap_minutes}m Free"
                })

    return processed_data

def get_valid_day_columns(driver):
    wait = WebDriverWait(driver, 15)
    wait.until(EC.presence_of_element_located((By.CLASS_NAME, "skemaBrikGruppe")))
    groups = driver.find_elements(By.XPATH, "//*[contains(@class, 'DagMedBrikker')]//*[contains(@class, 'skemaBrikGruppe')]/..")
    def get_x_pos(elem):
        transform = elem.get_attribute("transform")
        if not transform: return 99999
        match = re.search(r"translate\((\d+)", transform)
        return int(match.group(1)) if match else 99999
    return sorted(groups, key=get_x_pos)

def format_header(date_obj, is_today=False, is_tomorrow=False):
    date_str = date_obj.strftime("%A, %d %b")
    suffix = ""
    if is_today: suffix = "(Today)"
    elif is_tomorrow: suffix = "(Tomorrow)"
    else: suffix = "(Next Week)"
    return f"{date_str} {suffix}"

def update_schedule():
    options = Options()
    options.add_argument("--headless") 
    options.add_argument("-profile")
    options.add_argument(PROFILE_PATH)

    driver = None
    # Default output
    output = {"header": "Loading...", "lessons": [], "link": GENERIC_URL}
    
    now = datetime.now()
    current_weekday = now.weekday() 

    try:
        driver = webdriver.Firefox(options=options)
        
        target_date = now
        should_check_today = True
        
        # 1. Decide Initial URL (Use Generic unless it's the weekend)
        initial_url = GENERIC_URL

        # Weekend Logic -> Jump to Next Week
        if current_weekday > 4:
            days_ahead = 7 - current_weekday
            target_date = now + timedelta(days=days_ahead)
            initial_url = get_specific_url(target_date) # Must use specific link for next week
            should_check_today = False
            output["header"] = format_header(target_date)
            output["link"] = initial_url
        
        driver.get(initial_url)
        day_columns = get_valid_day_columns(driver)

        if should_check_today:
            # We are on the generic current week page
            if current_weekday < len(day_columns):
                today_lessons = extract_lessons_from_group(day_columns[current_weekday], now)
                
                # Check if finished today
                is_finished_today = False
                if not today_lessons:
                    is_finished_today = True
                elif now.timestamp() > today_lessons[-1]['end']:
                    is_finished_today = True
                
                if not is_finished_today:
                    output["lessons"] = today_lessons
                    output["header"] = format_header(now, is_today=True)
                    output["link"] = get_specific_url(now)
                else:
                    # Switch to Next School Day
                    if current_weekday == 4: # Friday -> Monday (Next Week)
                        target_date = now + timedelta(days=3)
                        target_url = get_specific_url(target_date)
                        
                        output["header"] = format_header(target_date)
                        output["link"] = target_url
                        
                        # RELOAD page for next week
                        driver.get(target_url)
                        day_columns = get_valid_day_columns(driver)
                        if len(day_columns) > 0:
                            output["lessons"] = extract_lessons_from_group(day_columns[0], target_date)
                            
                    else: # Mon-Thu -> Tomorrow (Same Page)
                        target_date = now + timedelta(days=1)
                        output["header"] = format_header(target_date, is_tomorrow=True)
                        output["link"] = get_specific_url(target_date)

                        next_idx = current_weekday + 1
                        if next_idx < len(day_columns):
                            output["lessons"] = extract_lessons_from_group(day_columns[next_idx], target_date)
        else:
            # Weekend Case (Already loaded next week's page)
            if len(day_columns) > 0:
                output["lessons"] = extract_lessons_from_group(day_columns[0], target_date)

    except Exception:
        # Fallback error
        output = {"header": "Error", "lessons": [{"type": "class", "time": "Error", "subject": "Check Script", "room": "!", "start": 0, "end": 0}], "link": ""}

    finally:
        if driver: driver.quit()
        os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
        with open(CACHE_FILE, "w") as f:
            json.dump(output, f)

if __name__ == "__main__":
    update_schedule()
