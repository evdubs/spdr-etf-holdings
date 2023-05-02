CREATE SCHEMA spdr;

CREATE TYPE spdr.sector AS ENUM
('Communication Services', 
  'Consumer Discretionary', 
  'Consumer Staples', 
  'Energy', 
  'Financials', 
  'Health Care', 
  'Industrials', 
  'Information Technology', 
  'Materials', 
  'Real Estate', 
  'Telecommunication Services', 
  'Utilities');
    
CREATE TYPE spdr.industry AS ENUM
('Aerospace & Defense', 
  'Air Freight & Logistics', 
  'Airlines', 
  'Auto Components',
  'Automobile Components',
  'Automobiles', 
  'Banks', 
  'Beverages', 
  'Biotechnology',
  'Broadline Retail',
  'Building Products', 
  'Capital Markets', 
  'Chemicals', 
  'Commercial Services & Supplies', 
  'Communications Equipment', 
  'Construction & Engineering', 
  'Construction Materials', 
  'Consumer Finance',
  'Consumer Staples Distribution & Retail',
  'Containers & Packaging', 
  'Distributors', 
  'Diversified Consumer Services', 
  'Diversified Financial Services', 
  'Diversified Telecommunication Services', 
  'Electric Utilities', 
  'Electrical Equipment', 
  'Electronic Equipment Instruments & Components', 
  'Energy Equipment & Services', 
  'Entertainment', 
  'Equity Real Estate Investment Trusts (Reits)',
  'Financial Services',
  'Food & Staples Retailing', 
  'Food Products',
  'Gas Utilities',
  'Ground Transportation',
  'Health Care Equipment & Supplies', 
  'Health Care Providers & Services',
  'Health Care REITs',
  'Health Care Technology',
  'Hotel & Resort REITs',
  'Hotels Restaurants & Leisure', 
  'Household Durables', 
  'Household Products', 
  'Independent Power And Renewable Electricity Producers', 
  'Industrial Conglomerates',
  'Industrial REITs',
  'Insurance', 
  'Interactive Media & Services', 
  'Internet & Direct Marketing Retail', 
  'Internet Software & Services', 
  'It Services', 
  'Leisure Products', 
  'Life Sciences Tools & Services', 
  'Machinery', 
  'Media', 
  'Metals & Mining', 
  'Multi-Utilities', 
  'Multiline Retail',
  'Office REITs',
  'Oil Gas & Consumable Fuels', 
  'Personal Products', 
  'Pharmaceuticals', 
  'Professional Services', 
  'Real Estate Management & Development',
  'Residential REITs',
  'Retail REITs',
  'Road & Rail', 
  'Semiconductors & Semiconductor Equipment', 
  'Software',
  'Specialized REITs',
  'Specialty Retail', 
  'Technology Hardware Storage & Peripherals', 
  'Textiles Apparel & Luxury Goods', 
  'Tobacco', 
  'Trading Companies & Distributors', 
  'Water Utilities'
  'Wireless Telecommunication Services');
    
CREATE TYPE spdr.sub_industry AS ENUM
('Aerospace & Defense', 
  'Air Freight & Logistics', 
  'Airlines', 
  'Airport Services', 
  'Alternative Carriers', 
  'Aluminum', 
  'Apparel Retail', 
  'Application Software', 
  'Asset Management & Custody Banks', 
  'Automotive Retail', 
  'Biotechnology',
  'Broadline Retail',
  'Building Products',
  'Cargo Ground Transportation',
  'Coal & Consumable Fuels',
  'Commercial & Residential Mortgage Finance',
  'Communications Equipment', 
  'Computer & Electronics Retail',
  'Consumer Staples Merchandise Retail',
  'Copper', 
  'Data Processing & Outsourced Services', 
  'Department Stores', 
  'Diversified Banks',
  'Diversified Financial Services',
  'Diversified Metals & Mining', 
  'Drug Retail', 
  'Electronic Components', 
  'Electronic Equipment & Instruments', 
  'Financial Exchanges & Data', 
  'Food Retail', 
  'General Merchandise Stores', 
  'Gold', 
  'Health Care Distributors', 
  'Health Care Equipment', 
  'Health Care Facilities', 
  'Health Care Services', 
  'Health Care Supplies', 
  'Home Entertainment Software', 
  'Home Furnishings', 
  'Home Improvement Retail', 
  'Homebuilding', 
  'Homefurnishing Retail', 
  'Household Appliances', 
  'Hypermarkets & Super Centers', 
  'Insurance Brokers', 
  'Integrated Oil & Gas', 
  'Integrated Telecommunication Services', 
  'Interactive Home Entertainment', 
  'Interactive Media & Services', 
  'Internet & Direct Marketing Retail', 
  'Internet Services & Infrastructure', 
  'Internet Software & Services', 
  'Investment Banking & Brokerage', 
  'It Consulting & Other Services', 
  'Life & Health Insurance',
  'Life Sciences Tools & Services',
  'Managed Health Care', 
  'Marine', 
  'Multi-Line Insurance', 
  'Oil & Gas Drilling', 
  'Oil & Gas Equipment & Services', 
  'Oil & Gas Exploration & Production', 
  'Oil & Gas Refining & Marketing', 
  'Other Diversified Financial Services',
  'Other Specialty Retail',
  'Passenger Airlines',
  'Passenger Ground Transportation',
  'Pharmaceuticals', 
  'Property & Casualty Insurance',
  'Rail Transportation'
  'Railroads',
  'Real Estate Services',
  'Regional Banks', 
  'Reinsurance', 
  'Research & Consulting Services', 
  'Semiconductors', 
  'Silver', 
  'Specialty Stores', 
  'Steel', 
  'Systems Software', 
  'Technology Hardware Storage & Peripherals', 
  'Thrifts & Mortgage Finance', 
  'Trucking', 
  'Wireless Telecommunication Services');
    
CREATE TABLE spdr.etf_holding
(
    etf_symbol text NOT NULL,
    date date NOT NULL,
    component_symbol text NOT NULL,
    weight numeric NOT NULL,
    sector spdr.sector,
    industry spdr.industry,
    sub_industry spdr.sub_industry,
    shares_held numeric NOT NULL,
    CONSTRAINT etf_holding_pkey PRIMARY KEY (date,
      etf_symbol,
      component_symbol),
    CONSTRAINT etf_holding_component_symbol_fkey FOREIGN KEY (component_symbol)
        REFERENCES nasdaq.symbol (act_symbol) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT etf_holding_etf_symbol_fkey FOREIGN KEY (etf_symbol)
        REFERENCES nasdaq.symbol (act_symbol) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION spdr.to_sector_etf(
	sector spdr.sector)
    RETURNS text
    LANGUAGE 'sql'
AS $BODY$
select
  case sector::text
    when 'Communication Services' then 'XLC'
    when 'Consumer Discretionary' then 'XLY'
    when 'Consumer Staples' then 'XLP'
    when 'Energy' then 'XLE'
    when 'Financials' then 'XLF'
    when 'Health Care' then 'XLV'
    when 'Industrials' then 'XLI'
    when 'Information Technology' then 'XLK'
    when 'Materials' then 'XLB'
    when 'Real Estate' then 'XLRE'
    when 'Utilities' then 'XLU'
  end;
$BODY$;

