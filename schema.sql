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
  'Diversified REITs',
  'Diversified Telecommunication Services',
  'Electric Utilities',
  'Electrical Equipment',
  'Electronic Equipment, Instruments & Components',
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
  'IT Services',
  'Independent Power & Renewable Electricity Producers',
  'Industrial Conglomerates',
  'Industrial REITs',
  'Insurance',
  'Interactive Media & Services',
  'Internet & Direct Marketing Retail',
  'Internet Software & Services',
  'Leisure Products',
  'Life Sciences Tools & Services',
  'Machinery',
  'Marine Transportation',
  'Media',
  'Metals & Mining',
  'Mortgage Real Estate Investment Trusts (REITs)',
  'Multi-Utilities',
  'Multiline Retail',
  'Office REITs',
  'Oil, Gas & Consumable Fuels',
  'Paper & Forest Products',
  'Passenger Airlines',
  'Personal Care Products',
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
  'Technology Hardware, Storage & Peripherals',
  'Textiles Apparel & Luxury Goods',
  'Tobacco',
  'Trading Companies & Distributors',
  'Transportation Infrastructure',
  'Water Utilities',
  'Wireless Telecommunication Services');
    
CREATE TYPE spdr.sub_industry AS ENUM
('Advertising',
  'Aerospace & Defense',
  'Agricultural & Farm Machinery',
  'Agricultural Products & Services',
  'Air Freight & Logistics',
  'Airlines',
  'Airport Services',
  'Alternative Carriers',
  'Aluminum',
  'Apparel Retail',
  'Apparel, Accessories & Luxury Goods',
  'Application Software',
  'Asset Management & Custody Banks',
  'Automobile Manufacturers',
  'Automotive Parts & Equipment',
  'Automotive Retail',
  'Biotechnology',
  'Brewers',
  'Broadcasting',
  'Broadline Retail',
  'Building Products',
  'Cable & Satellite',
  'Cargo Ground Transportation',
  'Casinos & Gaming',
  'Coal & Consumable Fuels',
  'Commercial & Residential Mortgage Finance',
  'Commercial Printing',
  'Commodity Chemicals',
  'Communications Equipment',
  'Computer & Electronics Retail',
  'Construction & Engineering',
  'Construction Machinery & Heavy Transportation Equipment',
  'Construction Materials',
  'Consumer Electronics',
  'Consumer Finance',
  'Consumer Staples Merchandise Retail',
  'Copper',
  'Data Center REITs',
  'Data Processing & Outsourced Services',
  'Department Stores',
  'Distillers & Vintners',
  'Distributors',
  'Diversified Banks',
  'Diversified Capital Markets',
  'Diversified Chemicals',
  'Diversified Financial Services',
  'Diversified Metals & Mining',
  'Diversified REITs',
  'Diversified Real Estate Activities',
  'Diversified Support Services',
  'Drug Retail',
  'Education Services',
  'Electric Utilities',
  'Electrical Components & Equipment',
  'Electronic Components',
  'Electronic Equipment & Instruments',
  'Electronic Manufacturing Services',
  'Environmental & Facilities Services',
  'Fertilizers & Agricultural Chemicals',
  'Financial Exchanges & Data',
  'Food Distributors',
  'Food Retail',
  'Footwear',
  'Forest Products',
  'Gas Utilities',
  'General Merchandise Stores',
  'Gold',
  'Health Care Distributors',
  'Health Care Equipment',
  'Health Care Facilities',
  'Health Care REITs',
  'Health Care Services',
  'Health Care Supplies',
  'Health Care Technology',
  'Heavy Electrical Equipment',
  'Highways & Railtracks',
  'Home Entertainment Software',
  'Home Furnishings',
  'Home Improvement Retail',
  'Homebuilding',
  'Homefurnishing Retail',
  'Hotel & Resort REITs',
  'Hotels, Resorts & Cruise Lines',
  'Household Appliances',
  'Household Products',
  'Houseware & Specialties',
  'Human Resource & Employment Services',
  'Hypermarkets & Super Centers',
  'IT Consulting & Other Services',
  'Independent Power Producers & Energy Traders',
  'Industrial Conglomerates',
  'Industrial Gases',
  'Industrial Machinery & Supplies & Components',
  'Industrial REITs',
  'Insurance Brokers',
  'Integrated Oil & Gas',
  'Integrated Telecommunication Services',
  'Interactive Home Entertainment',
  'Interactive Media & Services',
  'Internet & Direct Marketing Retail',
  'Internet Services & Infrastructure',
  'Internet Software & Services',
  'Investment Banking & Brokerage',
  'Leisure Facilities',
  'Leisure Products',
  'Life & Health Insurance',
  'Life Sciences Tools & Services',
  'Managed Health Care',
  'Marine Ports & Services',
  'Marine Transportation',
  'Marine',
  'Metal, Glass & Plastic Containers'
  'Mortgage REITs',
  'Motorcycle Manufacturers',
  'Movies & Entertainment',
  'Multi-Family Residential REITs',
  'Multi-Sector Holdings',
  'Multi-Utilities',
  'Multi-Line Insurance',
  'Office REITs',
  'Office Services & Supplies',
  'Oil & Gas Drilling',
  'Oil & Gas Equipment & Services',
  'Oil & Gas Exploration & Production',
  'Oil & Gas Refining & Marketing',
  'Oil & Gas Storage & Transportation',
  'Other Diversified Financial Services',
  'Other Specialized REITs',
  'Other Specialty Retail',
  'Packaged Foods & Meats',
  'Paper & Plastic Packaging Products & Materials',
  'Paper Products',
  'Passenger Airlines',
  'Passenger Ground Transportation',
  'Personal Care Products',
  'Pharmaceuticals',
  'Precious Metals & Minerals',
  'Property & Casualty Insurance',
  'Publishing',
  'Rail Transportation',
  'Railroads',
  'Real Estate Development',
  'Real Estate Operating Companies',
  'Real Estate Services',
  'Regional Banks',
  'Reinsurance',
  'Renewable Electricity',
  'Research & Consulting Services',
  'Restaurants'
  'Retail REITs',
  'Security & Alarm Services',
  'Self-Storage REITs',
  'Semiconductor Materials & Equipment',
  'Semiconductors',
  'Silver',
  'Single-Family Residential REITs',
  'Soft Drinks & Non-Alcoholic Beverages',
  'Specialized Consumer Services',
  'Specialized Finance',
  'Specialty Chemicals',
  'Specialty Stores',
  'Steel',
  'Systems Software',
  'Technology Distributors',
  'Technology Hardware, Storage & Peripherals',
  'Telecom Tower REITs',
  'Textiles',
  'Thrifts & Mortgage Finance',
  'Timber REITs',
  'Tires & Rubber',
  'Tobacco',
  'Trading Companies & Distributors',
  'Transaction & Payment Processing Services',
  'Trucking',
  'Water Utilities',
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

CREATE OR REPLACE FUNCTION spdr.is_market_etf(etf text) RETURNS boolean
    LANGUAGE sql
    AS $$
  select
    case etf
      when 'DIA' then true
      when 'MDY' then true
      when 'SLY' then true
      when 'SPSM' then true
      when 'SPY' then true
      else false
    end;
$$;

CREATE FUNCTION spdr.is_sector_etf(etf text) RETURNS boolean
    LANGUAGE sql
    AS $$
  select
    case etf
      when 'XLB' then true
      when 'XLC' then true
      when 'XLE' then true
      when 'XLF' then true
      when 'XLI' then true
      when 'XLK' then true
      when 'XLP' then true
      when 'XLRE' then true
      when 'XLU' then true
      when 'XLV' then true
      when 'XLY' then true
      else false
    end;
$$;

CREATE FUNCTION spdr.is_industry_etf(etf text) RETURNS boolean
    LANGUAGE sql
    AS $$
  select
    case etf
      when 'KBE' then true
      when 'KCE' then true
      when 'KIE' then true
      when 'KRE' then true
      when 'XAR' then true
      when 'XBI' then true
      when 'XES' then true
      when 'XHB' then true
      when 'XHE' then true
      when 'XHS' then true
      when 'XME' then true
      when 'XOP' then true
      when 'XPH' then true
      when 'XRT' then true
      when 'XSD' then true
      when 'XSW' then true
      when 'XTH' then true
      when 'XTL' then true
      when 'XTN' then true
      when 'XWEB' then true
      else false
    end;
$$;
