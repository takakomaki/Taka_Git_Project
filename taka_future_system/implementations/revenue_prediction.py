"""
Taka Future System - Revenue Prediction Algorithm
Version: 1.0
Created: 2025-12-11
"""

class RevenuePredictor:
    def __init__(self):
        self.revenue_sources = {
            "tours": {
                "year_1": 10000000,
                "year_2": 20000000,
                "year_3": 30000000,
                "growth_rate": 0.5
            },
            "ai_orchestration": {
                "year_1": 8000000,
                "year_2": 15000000,
                "year_3": 25000000,
                "growth_rate": 0.4
            },
            "curriculum": {
                "year_1": 7000000,
                "year_2": 12000000,
                "year_3": 18000000,
                "growth_rate": 0.3
            },
            "producership": {
                "year_1": 3000000,
                "year_2": 8000000,
                "year_3": 15000000,
                "growth_rate": 0.6
            },
            "publishing": {
                "year_1": 2000000,
                "year_2": 3000000,
                "year_3": 7000000,
                "growth_rate": 0.2
            },
            "international": {
                "year_1": 0,
                "year_2": 2000000,
                "year_3": 5000000,
                "growth_rate": 0.8
            }
        }
    
    def predict_year(self, year: int) -> dict:
        """指定年の収益予測"""
        if year < 1 or year > 3:
            raise ValueError("Year must be between 1 and 3")
        
        total = 0
        breakdown = {}
        
        for source, data in self.revenue_sources.items():
            if year == 1:
                revenue = data["year_1"]
            elif year == 2:
                revenue = data["year_2"]
            else:
                revenue = data["year_3"]
            
            breakdown[source] = revenue
            total += revenue
        
        return {
            "year": year,
            "total": total,
            "breakdown": breakdown,
            "formatted_total": f"¥{total:,}"
        }
    
    def predict_all_years(self) -> dict:
        """全3年の収益予測"""
        return {
            "year_1": self.predict_year(1),
            "year_2": self.predict_year(2),
            "year_3": self.predict_year(3)
        }
    
    def calculate_growth_scenario(self, scenario: str = "base") -> dict:
        """成長シナリオの計算"""
        scenarios = {
            "base": 1.0,
            "optimistic": 1.2,
            "conservative": 0.8
        }
        
        multiplier = scenarios.get(scenario, 1.0)
        predictions = self.predict_all_years()
        
        adjusted = {}
        for year_key, year_data in predictions.items():
            adjusted[year_key] = {
                **year_data,
                "total": int(year_data["total"] * multiplier),
                "formatted_total": f"¥{int(year_data['total'] * multiplier):,}"
            }
        
        return adjusted

# 使用例
if __name__ == "__main__":
    predictor = RevenuePredictor()
    
    print("=== 基本予測 ===")
    predictions = predictor.predict_all_years()
    for year_key, year_data in predictions.items():
        print(f"{year_key}: {year_data['formatted_total']}")
    
    print("\n=== 楽観的シナリオ ===")
    optimistic = predictor.calculate_growth_scenario("optimistic")
    for year_key, year_data in optimistic.items():
        print(f"{year_key}: {year_data['formatted_total']}")
    
    print("\n=== 保守的シナリオ ===")
    conservative = predictor.calculate_growth_scenario("conservative")
    for year_key, year_data in conservative.items():
        print(f"{year_key}: {year_data['formatted_total']}")

