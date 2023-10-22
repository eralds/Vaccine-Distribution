import pandas as pd
import os
import matplotlib.pyplot as plt

data_path = os.path.join('..', 'data', 'vaccine-distribution-data.xlsx')
df = pd.read_excel(data_path, 'VaccinePatients')
grouped_total = df.groupby('date')['patientSsNo'].nunique().reset_index()
grouped_total['cumulative_sum'] = grouped_total['patientSsNo'].cumsum()
two_dose_patients = df.groupby('patientSsNo').filter(lambda x: len(x) >= 2)
grouped_two_dose = two_dose_patients.groupby('date')['patientSsNo'].nunique().reset_index()
grouped_two_dose['cumulative_sum'] = grouped_two_dose['patientSsNo'].cumsum()

plt.figure(figsize=(8, 8))

plt.plot(grouped_total['date'].dt.strftime('%Y-%m-%d'), grouped_total['cumulative_sum'], label='Total Vaccinated Patients')
plt.plot(grouped_two_dose['date'].dt.strftime('%Y-%m-%d'), grouped_two_dose['cumulative_sum'], color='orange', label='Patients with Two Doses')

plt.xlabel('Date')
plt.ylabel('Number of Patients')
plt.title('Cumulative Number of Vaccinated Patients')
plt.tick_params(axis='x', rotation=45)
plt.legend()

plt.tight_layout()
plt.savefig("Question9.png")
plt.show()
