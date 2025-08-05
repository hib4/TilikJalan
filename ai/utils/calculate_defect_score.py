from datetime import datetime
def calculate_score(avg_conf: float, num_detections: int, taken_date:str, base_multiplier:float = 30.0):
    today = datetime.today()
    taken = datetime.strptime(taken_date, '%Y-%m')
    months_delta = (today.year - taken.year) * 12 + (today.month - taken.month)
    total_score = avg_conf * (1 + num_detections / 100)
    return (base_multiplier * total_score) / (months_delta/10)