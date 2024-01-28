import pandas as pd
import xlsxwriter
import sys

def write_sheet(writer, sheetName, df):
    # Convert the dataframe to an XlsxWriter Excel object.
    df.to_excel(writer, sheet_name=sheetName)

# Get the xlsxwriter workbook and worksheet objects.
    workbook = writer.book
    worksheet = writer.sheets[sheetName]

# Get the dimensions of the dataframe.
    (max_row, max_col) = df.shape

# Apply a conditional format to the required cell range.
    worksheet.conditional_format(1, 1, max_row, max_col, {"type": "3_color_scale",
                                         'min_color': "red",
                                         'mid_color': "white",
                                         'max_color': "blue",
                                         'min_value': -1, 
                                         'max_value': 1})
    
heatmap_df_path = sys.argv[1]
excel_path = "fabian_heatmap.xlsx"

df = pd.read_csv(heatmap_df_path, index_col="Unnamed: 0")

# Create a Pandas Excel writer using XlsxWriter as the engine.
writer = pd.ExcelWriter(excel_path, engine="xlsxwriter")
write_sheet(writer, "all_variants", df)
levels = [0.6, 0.7, 0.8, 0.9]
for l in levels:
    df = df[df["max_tf_value"] >= l]
    l_str = str(l)
    write_sheet(writer, l_str, df)
writer.close()